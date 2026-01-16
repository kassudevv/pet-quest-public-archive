using { /Fortnite.com/Devices }
using { /Verse.org/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { utils_module }
    
breakable_area<public> := class<unique>(creative_device):
    @editable Id<public>:int = 0
    @editable Price:float = 0.0
    @editable GoldBonus<public>:float = 0.0
    
    @editable HitDetector<public>:prop_manipulator_device=prop_manipulator_device{}
    @editable AreaDetector<public>:volume_device=volume_device{}

    @editable Barrier:barrier_device = barrier_device{}
    @editable AreaBorderEntityPosition<public>:creative_prop = creative_prop{}

    @editable TeleportIcon<public>:texture = Assets.UI.DarkUI.Areas.T_Teleports_Area_0

    var AreaComp:?area_component=false
    var _BorderEntity:?entity=false

    PriceDisplayMaterial :Assets.Materials.DynamicText.M_ProgrammaticBillboard= Assets.Materials.DynamicText.M_ProgrammaticBillboard{}
    AreaHintDisplayMaterial :Assets.Materials.DynamicText.M_UnlockNextAreaHint= Assets.Materials.DynamicText.M_UnlockNextAreaHint{}

    var Breakables<public>:[]breakable_module.Service.breakable = array{}

    Init():void=
        PopulatePriceDisplayMaterial(Price)
        PopulateNextAreaHintMaterial()

        BreakableService := GetGame().Breakables
        
        HitDetector.DamagedEvent.Subscribe(OnBreakableHit)

        AreaDetector.AgentEntersEvent.Subscribe(OnAgentEnteredArea)
        AreaDetector.AgentExitsEvent.Subscribe(OnAgentExitedArea)

        InitAreaBorderEntity()

    OnAgentEnteredArea(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[], C := Guy.Areas):
            C.SetCurrentArea(option. Self)

    OnAgentExitedArea(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[], C := Guy.Areas):
            if (C.CurrentArea? = Self):
                C.SetCurrentArea(false)

    # BorderEntityHolder:entity= entity{}
    InitAreaBorderEntity():void=
        if (InteractComponent := AreaComp?): 
            if:
                SimulationEntity := GetGame().GetSimulationEntity[]
            then:
                # BORDER BUTTON
                BorderEntity := Assets.SG.AreaBorderEntityVisuals{}
                set _BorderEntity = option. BorderEntity
                if (BorderComponent := BorderEntity.GetComponent[area_component]):
                    # area price. ex: [GOLD] 10K
                    PriceEntity := BorderComponent.AreaPriceEntity
                    if (Mesh := PriceEntity.GetComponent[mesh_component], CastedMesh := Assets.SG.SM_AreaPriceEntity[Mesh]):
                        set PriceDisplayMaterial.AreaId = Id*1.0
                        set CastedMesh.Material_0 = PriceDisplayMaterial

                    # area number. ex: Area 12
                    AreaHintEntity := BorderComponent.AreaHintEntity
                    if (Mesh := AreaHintEntity.GetComponent[mesh_component], CastedMesh := Assets.SG.SM_AreaHintEntity[Mesh]):
                        set AreaHintDisplayMaterial.AreaId = Id*1.0
                        set CastedMesh.Material_0 = AreaHintDisplayMaterial

                    AreaPurchaseEntity := BorderComponent.PurchaseEntity
                    if (Mesh := AreaPurchaseEntity.GetComponent[mesh_component], CastedMesh := Assets.SG.SM_PurchaseButtonMesh[Mesh]):
                        set CastedMesh.Material_0 = Assets.Materials.DynamicText.M_PurchaseBTN{AreaId := Id*1.0}


                    WallEntity := BorderComponent.WallEntity
                    if (Mesh := WallEntity.GetComponent[mesh_component], CastedMesh := Assets.Models.Gameplay.AreaBorder.SM_Wall[Mesh]):
                        set CastedMesh.Material_0 = Assets.Models.Gameplay.AreaBorder.M_AreaBorder{AreaId := Id*1.0}

                if (T := InteractComponent.Entity.GetComponent[transform_component].GlobalTransform). BorderEntity.SetGlobalTransform(T)
                SimulationEntity.AddEntities(array{BorderEntity})

                # PURCHASE BUTTON
                PurchaseEntity := InteractComponent.PurchaseEntity
                if (Interact := PurchaseEntity.GetComponent[area_purchase_interactable_component]):
                    set Interact.AreaId = Id
                    set Interact.Price = Price
                    Interact.SucceededEvent.Subscribe(OnPurchaseButton)
        else:
            Print("[⚠️ WARN] Area #{Id} - No AreaComp found..")

    OnPurchaseButton(Agent:agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            if (not Guy.Data.Areas.Find[Id]):
                if:
                    Guy.Resources.Has[guy_module.resource_type.Gold, Price]

                    set Guy.Data.Areas += array{Id}
                    Guy.Data.Save[]
                then:
                    Guy.Events.AreaUnlocked.Signal(Id)
                    Guy.Resources.Remove(guy_module.resource_type.Gold, Price)
                    GetGame().Analytics.AreaUnlock.Award(Guy.Player)
                    RefreshLock(Player)
                    DoAreaUnlockAnimForPlayer(Guy)
                else:
                    spawn. Guy.UI.Notifications.PlayMessage("You don't have enough gold...", ?IsError := true)
            else:
                spawn. Guy.UI.Notifications.PlayMessage("You already have this area...", ?IsError := true)

    DoAreaUnlockAnimForPlayer(Guy:guy_module.guy):void=
        if:
            SimulationEntity := GetGame().GetSimulationEntity[]

            not AreaBorderEntityPosition.IsNullPosition[]
        then:
            GetGame().SFX.AreaUnlock.Play(Guy.Player)
            spawn. Guy.UI.Notifications.PlayMessage("Congrats! You unlocked Area #{Id+1}.", ?Duration := 5.0)
        
            GetGame().SFX.GroundBreaking.Play(Guy.Player)

            var ParticleSpawnPos:luf_xform= AreaBorderEntityPosition.GetTransform().ToLUF()
            set ParticleSpawnPos.Translation = ParticleSpawnPos.Translation + luf_vec3{Up := -6.0}
            set ParticleSpawnPos.Scale = luf_vec3{Left:=10.0,Up:=10.0,Forward:=10.0}
            ParticleEntity := entity{}
            ParticleEntity.SetGlobalTransform(ParticleSpawnPos)
            ParticleEntity.SetPresentableToPlayers(option. array{Guy.Player})
            SimulationEntity.AddEntities(array{ParticleEntity})
            ParticleEntity.AddComponents(array{Assets.SG.VFX_AreaUnlock{Entity := ParticleEntity}})
            spawn. DelayedDispose(ParticleEntity, 10.0)

    DelayedDispose(E:entity, Time:float)<suspends>:void=
        Sleep(Time)
        E.RemoveFromParent()

    PopulateNextAreaHintMaterial():void=
        AreaNumber := Id + 1
        Digits := EncodeAreaStringIntoDigits("{AreaNumber}")
        set AreaHintDisplayMaterial.Digit1 = Digits(0)
        set AreaHintDisplayMaterial.Digit2 = Digits(1)

    PopulatePriceDisplayMaterial(Value:float):void=
        # Normalized Price (e.g. 1420*10^3 -> 1.42*10^6)
        var ValueAsBigNum:big_number = big_number{Value := Value * 1.0, Exponent := 0}.Normalize()
        Normalized := ValueAsBigNum.NormalizeToNearestNumberSet()
        # Stringified Price (e.g. "1.42M")
        Stringified := ValueAsBigNum.Format()
        # What index location to place the dot at
        DotPosition : float = "{Stringified[1]}" = "." and 1.0 or "{Stringified[2]}" = "." and 2.0 or 0.0
        DigitsAndSuffix := FormatBigNumberWithSuffixSeparate(ValueAsBigNum)
        Digits := EncodeStringIntoDigits(DigitsAndSuffix(0), ?ShouldLeftPad:=logic{Value >= 1000.0})

        set PriceDisplayMaterial.Digit1 = Digits(0)
        set PriceDisplayMaterial.Digit2 = Digits(1)
        set PriceDisplayMaterial.Digit3 = Digits(2)
        set PriceDisplayMaterial.Digit4 = Digits(3)
        set PriceDisplayMaterial.SuffixIndex = DigitsAndSuffix(1) * 1.0

        # Calculate XOFfset to center Price under Area {Nr}
        var XOffset:float=0.38
        if (Digits(0) <> 0.0). set XOffset = 0.31
        if (Digits(1) <> 0.0). set XOffset = 0.24
        if (Digits(2) <> 0.0). set XOffset = 0.17
        if (Digits(3) <> 0.0). set XOffset = 0.1
        if (DigitsAndSuffix(1) <> 0). set XOffset = 0.0
        set PriceDisplayMaterial.XOffset = XOffset

    InitBreakable<public>(Prop:creative_prop):void=
        # x = area id
        # e = exponent (1.8x?)
        # max health = 29.0 + maxhealth*e^x 
        for (Definition : GetGame().Breakables.BreakableDefinitions2, TagView := Prop.GetTags(), TagView.Has[Definition.Tag]):

            # health scaling calculations. very fast first 10 areas, then slows down to avoid run-off
            var MaxHealth:float=0.0
            if (Id <= 9):
                set MaxHealth = Definition.MaxHealth * Pow(1.79, Id*1.0)
            else:
                LastMax := Definition.MaxHealth * Pow(1.79, 9*1.0)
                set MaxHealth = LastMax+Definition.MaxHealth* Pow(1.42, Id*1.0)
            
            Breakable := breakable_module.Service.breakable {Definition := Definition, Prop := Prop, Area := Self, MaxHealth := MaxHealth}
            Breakable.Init()
            set Breakables += array{Breakable}
            return
            
    # Get breakable being looked at and do damage
    OnBreakableHit(Agent : agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            Guy.Breakables.OnActivatedPropManipulatorDamagedEvent(Self)

    RefreshLock<public>(Player:player):void=
        if (Guy := Player.GetGuy[]):
            IsUnlocked := logic{Guy.Data.Areas.Find[Id]}
            if (IsUnlocked?). Barrier.AddToIgnoreList(Player) else. Barrier.RemoveFromIgnoreList(Player) 

    RefreshVisibility<public>():void=
        ShowToPlayers := GetPlayersAreaIsLockedFor()
        if (BorderEntity := _BorderEntity?). BorderEntity.SetPresentableToPlayers(option. ShowToPlayers)

    GetPlayersAreaIsLockedFor():[]player=
        var Result:[]player = for (Player->Guy:GetGame().Guys.Guys, not Guy.Data.Areas.Find[Id]). Player
        Result

    GetRandomBreakable<public>()<transacts><decides>:breakable_module.Service.breakable=
        Active := for (B:Breakables, B.Active?). B
        Active[GetRandomInt(0,Active.Length-1)]

    GetClosestBreakable<public>(Guy:guy_module.guy)<transacts><decides>:breakable_module.Service.breakable=
        Active := for (B:Breakables, B.Active?). B
        
        var ClosestDist:float=-1.0
        var Closest:breakable_module.Service.breakable=Active[0]
        if:
            Fort := Guy.Player.SafeFortCharacter[]
            FortPos := Fort.GetTransform()
        then:
            for (C:Active, C.Prop.IsValid[], Position:=C.Prop.GetTransform()):
                DistanceBetween := FastDistance(Position.Translation, FortPos.Translation)
                if (ClosestDist = -1.0 or DistanceBetween < ClosestDist):
                    set ClosestDist = DistanceBetween
                    set Closest = C
            
        Closest

service<public> := class(main_module.base_service):
    @editable SetCurrentAreaBorderMPC<public>:cinematic_sequence_device=cinematic_sequence_device{}
    @editable HealthBarPropAsset<public>:creative_prop_asset=DefaultCreativePropAsset
    
    var Areas<public>:[]breakable_area = array{}

    Init<override>():void=
        set Areas = GetTaggedDevices(device_identifier_tags.area{}, breakable_area)

        if (SimEntity := GetGame().GetSimulationEntity[]):
            for (AreaComp : SimEntity.FindDescendantComponents(area_component), Area := GetAreaFromId[AreaComp.AreaId]):
                set Area.AreaComp = option. AreaComp

        var ExistingAreas:[int]logic=map{}
        for (Area:Areas):
            Area.Init()

            if (ExistingAreas[Area.Id]?):
                Print("--------- WARNING ------------- DUPLICATE AREA ID {Area.Id}")
            else:
                if. set ExistingAreas[Area.Id] = true

    Start<override>()<suspends>:void=
        spawn. HandleVisibilityStateEvents()

        Sleep(3.0)

        for (IDX:=1..25, Area := GetAreaFromId[IDX]):
            if (Egg := GetGame().Eggs.IdToEgg[Area.Id-1], Reward := Egg.Rewards[2]):
                if (Def := GetGame().Pets.GetDefinitionFromName[Reward.Pet]):
                    E:float=1.45
                    PetDamage := 13.0+(Pow(Def.Level*1.0, E))
                    GoldGainPerHit := PetDamage * (1.0 + Area.GoldBonus)
                    GoldPerMinute := GoldGainPerHit*4.0*60.0
                    MinutesToUnlockArea := Area.Price/GoldPerMinute
                    Print("Area {Area.Id} | level= {Def.Level} | time to unlock area= {MinutesToUnlockArea}min")

    HandleVisibilityStateEvents<public>()<suspends>:void=
        Guys := GetGame().Guys.Guys
        for (Guy:Guys):
            for (AreaId:Guy.Data.Areas, Area:=GetAreaFromId[AreaId]). Area.RefreshLock(Guy.Player)
            spawn. ListenVisibilityStateEvents(Guy)

        loop:
            Guy := GetGame().Events.PlayerJoined.Await()
            for (AreaId:Guy.Data.Areas, Area:=GetAreaFromId[AreaId]). Area.RefreshLock(Guy.Player)
            spawn. ListenVisibilityStateEvents(Guy)

    ListenVisibilityStateEvents<public>(Guy:guy_module.guy)<suspends>:void=        
        race:
            loop:
                AreaUnlocked := Guy.Events.AreaUnlocked.Await()
                if (Area := GetAreaFromId[AreaUnlocked]). Area.RefreshLock(Guy.Player)
            loop:
                Guy.Events.Rebirthed.Await()
                for (Area:Areas). Area.RefreshLock(Guy.Player)
            Guy.Events.Left.Await()

    GetAreaFromId<public>(Id:int)<transacts><decides>:breakable_area=(for (Area:Areas, Area.Id=Id). Area)[0]

FormatBigNumberWithSuffixSeparate<public>(Num : big_number):tuple(string, int)=
        if (Num.Value = 0). return ("0", 0)

        Normalized := Num.NormalizeToNearestNumberSet()

        # Under 1K should just return value as string.
        if (Normalized.Exponent < 3, Result := Floor[Normalized.Value]). return ("{Result}", 0)

        var String : string= "{Normalized.Value}"
        var TargetLength : int = Normalized.Value >= 100.0 and 3 or 4

        # Remove unnecessary zeroes from string.
        if:
            NewValue := String.Remove[TargetLength, String.Length]
            set String = NewValue

        var SuffixIndex : int = 0
        if:
            Suffix := Quotient[Normalized.Exponent, 3]
            set SuffixIndex = Suffix

        (String, SuffixIndex)

LeftPad<public>(Input : []float):[]float=
    Len := Input.Length

    var Output : []float = Input
    for (IDX := 0..4-Len). set Output = array{0.0} + Output
    Output

    # Map Digits to index on SpriteSheet
EncodeStringIntoDigits<public>(String : string, ?ShouldLeftPad:logic=false):tuple(float, float, float, float)=
    DigitMapping : [string]float = map{"." => 1.0, "1" => 2.0, "2" => 3.0, "3" => 4.0, "4" => 5.0, "5" => 6.0,
                                        "6" => 7.0, "7" => 8.0, "8" => 9.0, "9" => 10.0, "0" => 11.0, ":" => 12.0}

    Len := String.Length

    Digits := for (IDX := 0..Len). DigitMapping["{Char := String[IDX]}"] or 0.0
    PaddedDigits := LeftPad(Digits)

    Final := ShouldLeftPad? and PaddedDigits or Digits

    Result := (Final[0] or 0.0, Final[1] or 0.0, Final[2] or 0.0, Final[3] or 0.0)
    Result

    # if:
    #     Result := (PaddedDigits[0], PaddedDigits[1], PaddedDigits[2], PaddedDigits[3])
    # then:
    #     Result
    # else:
    #     (0.0, 0.0, 0.0, 0.0)

    # Map Digits to index on SpriteSheet
EncodeAreaStringIntoDigits<public>(String : string):tuple(float, float)=
    DigitMapping : [string]float = map{"." => 1.0, "1" => 2.0, "2" => 3.0, "3" => 4.0, "4" => 5.0, "5" => 6.0,
                                        "6" => 7.0, "7" => 8.0, "8" => 9.0, "9" => 10.0, "0" => 11.0, ":" => 12.0}

    Len := String.Length

    Digits := for (IDX := 0..Len). DigitMapping["{Char := String[IDX]}"] or 0.0

    Result := (Digits[0] or 0.0, Digits[1] or 0.0)
    Result


    