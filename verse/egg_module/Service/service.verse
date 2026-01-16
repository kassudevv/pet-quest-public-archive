using { /Fortnite.com/Devices }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

egg_definition_reward<public> := struct<concrete>:
    @editable Pet<public>:string=""
    @editable Chance<public>:float=0.0 #Rewards := array{("Turtle", 0.2),("Dog", 0.4),("Cat", 0.4)}},

egg_definition<public> := class<concrete>():
    @editable Id<public>:int = 0
    @editable Name<public> : string = "Unknown"
    @editable Price<public>:float=0.0
    @editable Rewards<public>:[]egg_definition_reward=array{}
    
    
    @editable Icon<public>:texture = Assets.Models.Pets.Icons.T_Pet_Icon
    @editable Interactables:[]subtype(entity) = array{}
    @editable _Positions<public>:[]creative_prop=array{}
    var Positions<public>:[]xyz_xform = array{}

    var EggLockEntities<public>:[]entity = array{}
    var EggInfoEntities<public>:[]entity = array{}

service<public> := class(main_module.base_service):
    @editable AutoHatchingToggle<public>:switch_device=switch_device{}

    # Egg map (Id => Definition)
    var IdToEgg<public>:[int]egg_definition = map{}
    var NameToEgg<public>:[string]egg_definition = map{}

    GetDefinition<public>(Id:int)<transacts><decides>:egg_definition=IdToEgg[Id]
    GetDefinitionFromName<public>(Name:string)<transacts><decides>:egg_definition=NameToEgg[Name]

    Init<override>():void=
        for (Idx->Egg : EggDefinitions):
            # InitEggPurchasables(Egg)
            if. set IdToEgg[Idx] = Egg
            if. set NameToEgg[Egg.Name] = Egg

        AutoHatchingToggle.TurnedOnEvent.Subscribe(OnEnableAutoHatch)
        AutoHatchingToggle.TurnedOffEvent.Subscribe(OnDisableAutoHatch)
        
        if (SimEntity := GetGame().GetSimulationEntity[]):
            for (EggComp : SimEntity.FindDescendantComponents(egg_component), Egg := GetDefinition[EggComp.EggId]):
                InitEggComp(EggComp, Egg)

                if (TC := EggComp.Entity.GetComponent[transform_component]). set Egg.Positions += array{TC.GlobalTransform.FromLUF()}

    var PriceMaterialCache:[int]Assets.Materials.DynamicText.M_ProgrammaticBillboard=map{}
    var OddsMaterialCache:[int]Assets.Models.Eggs.Locked.M_OddsInfo_Inst=map{}
    InitEggComp(Comp:egg_component, Egg:egg_definition):void=
        if (not PriceMaterialCache[Egg.Id]). if. set PriceMaterialCache[Egg.Id] = Assets.Materials.DynamicText.M_ProgrammaticBillboard{}
        PriceMaterial := PriceMaterialCache[Egg.Id] or Assets.Materials.DynamicText.M_ProgrammaticBillboard{}
        PopulatePriceDisplayMaterial(PriceMaterial, Egg.Price)


        InfoMaterial := OddsMaterialCache[Egg.Id] or MakeInfoMaterial(Egg.Rewards)
        set InfoMaterial.AreaId = Egg.Id*1.0
        if (not OddsMaterialCache[Egg.Id], set OddsMaterialCache[Egg.Id] = InfoMaterial) {}

        # InfoMaterial := OddsMaterialCache[Egg.Id] or Assets.Models.Eggs.Locked.M_OddsInfo_Inst{}
        # if (not OddsMaterialCache[Egg.Id], set OddsMaterialCache[Egg.Id] = InfoMaterial) {}
        # spawn. PopulateInfoMaterial(InfoMaterial, Egg.Rewards)


        if (Transform := Comp.Entity.GetComponent[transform_component]):
            HolderEntity := entity{}
            HolderEntity.SetGlobalTransform(Transform.GlobalTransform)

            LockEntity:entity=Assets.Models.Eggs.Locked.EggLockedEntity{}
            LockEntity.SetLocalTransform(luf_xform{Translation := luf_vec3{Up := 48.0}, Scale := luf_vec3{Up := 1.5, Left:=1.5,Forward:=1.5}})
            if (Mesh := LockEntity.GetComponent[mesh_component], Casted := Assets.Models.Eggs.Locked.locked_egg[Mesh]):
                set Casted.Material_0 = Assets.Models.Eggs.Locked.M_EggLock_MPCControlled{AreaId := Egg.Id*1.0}
            set Egg.EggLockEntities += array. LockEntity
            HolderEntity.AddEntities of array. LockEntity

            InfoEntity:entity=Assets.Models.Eggs.Locked.EggInfoEntity{}
            if (MeshComp := InfoEntity.GetComponent[mesh_component], Mesh := Assets.Models.Eggs.Locked.SM_Info[MeshComp]). set Mesh.Info = InfoMaterial
            InfoEntity.SetLocalTransform(luf_xform{Translation := luf_vec3{Up := 250.0, Forward := 64.0}, Scale := luf_vec3{Up := 1.0, Left:=1.0,Forward:=1.0}})
            set Egg.EggInfoEntities += array. InfoEntity
            # InfoEntity.SetPresentableToPlayers(PresentableHiddenToAll)
            HolderEntity.AddEntities of array. InfoEntity

            if (PurchaseComp := Comp.InteractEntity.GetComponent[egg_purchase_interactable_component]):
                set PurchaseComp.AreaId = Egg.Id
                spawn. ListenForEggPurchase(Egg, PurchaseComp)

            if (PriceComp := Comp.PriceTagEntity.GetComponent[mesh_component], Mesh := Assets.Models.Eggs.Locked.SM_PriceTag[PriceComp]):
                set Mesh.Price = PriceMaterial

            if (SE := GetGame().GetSimulationEntity[]). SE.AddEntities(array{HolderEntity})

    Start<override>():void=
        block {}
        # spawn. HandleVisibilityStateEvents()

    OnEnableAutoHatch(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[]):
            set Guy.Data.AutoHatchEnabled = true
            if. Guy.Data.Save[]

    OnDisableAutoHatch(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[]):
            set Guy.Data.AutoHatchEnabled = false
            if. Guy.Data.Save[]

    # HandleVisibilityStateEvents<public>()<suspends>:void=
    #     for (Egg:EggDefinitions). RefreshEggVisibility(Egg)

    #     Guys := GetGame().Guys.Guys
    #     for (Guy:Guys). spawn. ListenVisibilityStateEvents(Guy)

    #     loop:
    #         Guy := GetGame().Events.PlayerJoined.Await()
    #         for (Egg:EggDefinitions). RefreshEggVisibility(Egg)
    #         spawn. ListenVisibilityStateEvents(Guy)

    # ListenVisibilityStateEvents<public>(Guy:guy_module.guy)<suspends>:void=        
    #     race:
    #         loop:
    #             AreaUnlocked := Guy.Events.AreaUnlocked.Await()
    #             if (Egg := GetDefinition[AreaUnlocked]). RefreshEggVisibility(Egg)
    #         loop:
    #             Guy.Events.Rebirthed.Await()
    #             for (Egg:EggDefinitions). RefreshEggVisibility(Egg)
    #         Guy.Events.Left.Await()

    RefreshEggVisibility(Egg:egg_definition):void=
        PlayersEggIsLockedFor:[]player = GetPlayersEggIsLockedFor(Egg.Id)
        PlayersEggIsEnabledFor:[]player = GetPlayersEggIsUnlockedFor(Egg.Id)
        
        for (E:Egg.EggLockEntities). E.SetPresentableToPlayers(option. PlayersEggIsLockedFor)
        for (E:Egg.EggInfoEntities). E.SetPresentableToPlayers(option. PlayersEggIsEnabledFor)

    GetPlayersEggIsLockedFor(EggId:int):[]player=
        var Result:[]player = for (Player->Guy:GetGame().Guys.Guys, not Guy.Data.Areas.Find[EggId]). Player
        Result

    GetPlayersEggIsUnlockedFor(EggId:int):[]player=
        var Result:[]player = for (Player->Guy:GetGame().Guys.Guys, Guy.Data.Areas.Find[EggId]). Player
        Result

    ListenForEggPurchase(Egg:egg_definition, Comp:egg_purchase_interactable_component)<suspends>:void=
        loop:
            InteractingAgent := Comp.SucceededEvent.Await()
            spawn. DoEggPurchase(Egg, InteractingAgent)

            if (false?). break # suppress error

    DoEggPurchase(Egg:egg_definition, Agent:agent)<suspends>:void=
        if:
            Guy := player[Agent].GetGuy[]
            not Guy.Eggs.IsInAnimation?
        then:
            if:
                Guy.Data.Areas.Find[Egg.Id]
            then:
                if:
                    Guy.Resources.Has[guy_module.resource_type.Gold, Egg.Price]
                then:
                    if (Guy.Data.AutoHatchEnabled?, Fort := Guy.Player.SafeFortCharacter[], StartPos := Fort.GetTransform().Translation):
                        race:
                            loop:
                                if:
                                    Guy.Resources.Has[guy_module.resource_type.Gold, Egg.Price]
                                    CurrFort := Guy.Player.SafeFortCharacter[]
                                    CurrPos := CurrFort.GetTransform().Translation
                                    Dist := FastDistance(CurrPos,StartPos)
                                    Dist < 256.0
                                then:
                                    spawn. Guy.UI.Notifications.PlayMessage("Walk away to stop hatching. (Auto-hatching is enabled)")
                                    if:
                                        Pet := RollEgg[Guy,Egg]
                                    then:
                                        Guy.Resources.Remove(guy_module.resource_type.Gold, Egg.Price)
                                        set Guy.Data.EggsHatched += 1.0
                                        Guy.Events.EggHatched.Signal(Egg.Id)
                                        spawn. DelayedAwardPet(Guy, Pet)
                                        spawn. Guy.Eggs.PlayEggUnlockAnimationWithParams(Egg, Pet, ?IsNew := logic{not Guy.Inventory.Pets.Has[Pet.Id]})
                                        Sleep(3.1)
                                        if (Pet.Name = Egg.Rewards[0].Pet):
                                            GetGame().Analytics.HatchGreat.Award(Guy.Player)
                                            GetGame().SFX.UnlockRarePet.Play(Guy.Player)
                                        else if (Pet.Name = Egg.Rewards[1].Pet):
                                            GetGame().Analytics.HatchGood.Award(Guy.Player)
                                            GetGame().SFX.UnlockGoodPet.Play(Guy.Player)
                                        else:
                                            GetGame().Analytics.Hatch.Award(Guy.Player)
                                    Sleep(0.1)
                                else:
                                    # spawn. Guy.UI.Notifications.PlayMessage("Stopped auto-hatching.", ?IsError := true)
                                    return
                            Guy.Events.Left.Await()
                    else:
                        if:
                            Pet := RollEgg[Guy,Egg]
                        then:
                            Guy.Resources.Remove(guy_module.resource_type.Gold, Egg.Price)
                            set Guy.Data.EggsHatched += 1.0
                            Guy.Events.EggHatched.Signal(Egg.Id)
                            spawn. DelayedAwardPet(Guy, Pet)
                            spawn. Guy.Eggs.PlayEggUnlockAnimationWithParams(Egg, Pet, ?IsNew := logic{not Guy.Inventory.Pets.Has[Pet.Id]})
                            Sleep(3.1)
                            if (Pet.Name = Egg.Rewards[0].Pet):
                                GetGame().Analytics.HatchGreat.Award(Guy.Player)
                                GetGame().SFX.UnlockRarePet.Play(Guy.Player)
                            else if (Pet.Name = Egg.Rewards[1].Pet):
                                GetGame().Analytics.HatchGood.Award(Guy.Player)
                                GetGame().SFX.UnlockGoodPet.Play(Guy.Player)
                            else:
                                GetGame().Analytics.Hatch.Award(Guy.Player)
                        else:
                            spawn. Guy.UI.Notifications.PlayMessage("Something went wrong rolling this Egg. (Egg Identifier: #{Egg.Id})", ?IsError := true)
                else:
                    spawn. Guy.UI.Notifications.PlayMessage("You don't have enough Gold!", ?IsError := true)
            else:
                # spawn. Guy.UI.Notifications.PlayMessage("Unlock this Egg by reaching Area {Egg.Id+1}!", ?IsError := true)

    DelayedAwardPet<public>(Guy:guy_module.guy, Pet:pet_module.Service.pet_definition)<suspends>:void=
        var Awarded:logic=false
        race:
            block:
                Sleep(6.0)
                if (not Awarded?):
                    set Awarded = true

                    SkipAutoEquip := logic{Guy.Data.QuestId = 7 or Guy.Data.QuestId = 8}
                    Guy.Inventory.Pets.AwardPet(Pet.Id, ?SkipAutoEquip := SkipAutoEquip)
            block:
                Guy.Events.Left.Await()
                if (not Awarded?):
                    set Awarded = true
                    Guy.Inventory.Pets.AwardPet(Pet.Id)

    DigitMapping : [string]float = map{" " => 0.0, "." => 1.0, "1" => 2.0, "2" => 3.0, "3" => 4.0, "4" => 5.0, "5" => 6.0,
                                       "6" => 7.0, "7" => 8.0, "8" => 9.0, "9" => 10.0, "0" => 11.0, "?" => 12.0}

    PopulateInfoMaterial(Material:Assets.Models.Eggs.Locked.M_OddsInfo_Inst, Rewards:[]egg_definition_reward)<suspends>:void=
        Sleep(GetRandomFloat(1.0,5.0))
        # rewards are rarest first
        #Rewards := array{("Turtle", 0.2),("Dog", 0.4),("Cat", 0.4)}},
        # under 1% chance special case. instead of roudning to 0, should display the comma 0.03 = ".3%" 

        PetService := GetGame().Pets
        DefinitionAndChance:[]tuple(pet_module.Service.pet_definition, float) = for (Reward : Rewards, Definition := PetService.GetDefinitionFromName[Reward.Pet]). (Definition, Reward.Chance)
        
        for (Idx->T:DefinitionAndChance, Pet := T(0), Chance := T(1)):
            NumberRounded:=Round[Chance*100.0] or 0
            NumberRoundedSpecial:=Round[Chance*1000.0] or 0
            ChanceAsString:string = if (Chance > 0.01) then. "{NumberRounded < 10 and " " or ""}{NumberRounded}" else. ".{NumberRoundedSpecial}"

            if. Idx = 0 then. Print("Pet := {Pet.Name}")
            if. Idx = 0 then. Print("ChanceAsString := '{ChanceAsString},'") 

            Digit0 := ChanceAsString[0] or Err("Failed to get digit 0")
            Digit1 := ChanceAsString[1] or Err("Failed to get digit 1")

            DigitMapping0:float = DigitMapping["{Char := Digit0}"] or 12.0
            DigitMapping1:float = DigitMapping["{Char := Digit1}"] or 12.0

            if. Idx = 0 then. Print("Digit0 := {Digit0}")
            if. Idx = 0 then. Print("Digit1 := {Digit1}")

            if (Idx = 0). set Material.Digit0_0 = DigitMapping0
            if (Idx = 0). set Material.Digit0_1 = DigitMapping1
            if (Idx = 0). set Material.Icon0 = Pet.Icon

            if (Idx = 1). set Material.Digit1_0 = DigitMapping0
            if (Idx = 1). set Material.Digit1_1 = DigitMapping1
            if (Idx = 1). set Material.Icon1 = Pet.Icon

            if (Idx = 2). set Material.Digit2_0 = DigitMapping0
            if (Idx = 2). set Material.Digit2_1 = DigitMapping1
            if (Idx = 2). set Material.Icon2 = Pet.Icon

    MakeInfoMaterial(Rewards:[]egg_definition_reward):Assets.Models.Eggs.Locked.M_OddsInfo_Inst=
        # rewards are rarest first
        #Rewards := array{("Turtle", 0.2),("Dog", 0.4),("Cat", 0.4)}},
        # under 1% chance special case. instead of roudning to 0, should display the comma 0.03 = ".3%" 

        PetService := GetGame().Pets
        DefinitionAndChance:[]tuple(pet_module.Service.pet_definition, float) = for (Reward : Rewards, Definition := PetService.GetDefinitionFromName[Reward.Pet]). (Definition, Reward.Chance)

        var Digit0_0:float=0.0
        var Digit0_1:float=0.0
        var Icon0:texture = Assets.Models.Pets.Icons.T_Pet_Icon
        var IsMega0:float=0.0

        var Digit1_0:float=0.0
        var Digit1_1:float=0.0
        var Icon1:texture = Assets.Models.Pets.Icons.T_Pet_Icon

        var Digit2_0:float=0.0
        var Digit2_1:float=0.0
        var Icon2:texture = Assets.Models.Pets.Icons.T_Pet_Icon
        
        for (Idx->T:DefinitionAndChance, Pet := T(0), Chance := T(1)):
            NumberRounded:=Round[Chance*100.0] or 0
            NumberRoundedSpecial:=Round[Chance*1000.0] or 0
            ChanceAsString:string = if (Chance > 0.01) then. "{NumberRounded < 10 and " " or ""}{NumberRounded}" else. ".{NumberRoundedSpecial}"

            if:
                Digit0 := ChanceAsString[0]
                Digit1 := ChanceAsString[1]
            then:
                DigitMapping0:float = DigitMapping["{Char := Digit0}"] or 12.0
                DigitMapping1:float = DigitMapping["{Char := Digit1}"] or 12.0

                if (Idx = 0). set Digit0_0 = DigitMapping0
                if (Idx = 0). set Digit0_1 = DigitMapping1
                if (Idx = 0). set Icon0 = PetService.GetPetIconPath(Pet.Name)
                if (Idx = 0, Pet.IsMega?). set IsMega0 = 1.0

                if (Idx = 1). set Digit1_0 = DigitMapping0
                if (Idx = 1). set Digit1_1 = DigitMapping1
                if (Idx = 1). set Icon1 = PetService.GetPetIconPath(Pet.Name)

                if (Idx = 2). set Digit2_0 = DigitMapping0
                if (Idx = 2). set Digit2_1 = DigitMapping1
                if (Idx = 2). set Icon2 = PetService.GetPetIconPath(Pet.Name)

        return Assets.Models.Eggs.Locked.M_OddsInfo_Inst:
            Digit0_0 := Digit0_0
            Digit0_1 := Digit0_1
            Icon0 := Icon0
            IsMega0 := IsMega0

            Digit1_0 := Digit1_0
            Digit1_1 := Digit1_1
            Icon1 := Icon1

            Digit2_0 := Digit2_0
            Digit2_1 := Digit2_1
            Icon2 := Icon2

    PopulatePriceDisplayMaterial(Material:Assets.Materials.DynamicText.M_ProgrammaticBillboard,Value:float):void=
        # Normalized Price (e.g. 1420*10^3 -> 1.42*10^6)
        var ValueAsBigNum:utils_module.big_number = utils_module.big_number{Value := Value * 1.0, Exponent := 0}.Normalize()
        Normalized := ValueAsBigNum.NormalizeToNearestNumberSet()
        # Stringified Price (e.g. "1.42M")
        Stringified := ValueAsBigNum.Format()
        # What index location to place the dot at
        DotPosition : float = "{Stringified[1]}" = "." and 1.0 or "{Stringified[2]}" = "." and 2.0 or 0.0
        DigitsAndSuffix := area_module.Service.FormatBigNumberWithSuffixSeparate(ValueAsBigNum)
        Digits := area_module.Service.EncodeStringIntoDigits(DigitsAndSuffix(0), ?ShouldLeftPad:=logic{Value >= 1000.0})

        set Material.Digit1 = Digits(0)
        set Material.Digit2 = Digits(1)
        set Material.Digit3 = Digits(2)
        set Material.Digit4 = Digits(3)
        set Material.SuffixIndex = DigitsAndSuffix(1) * 1.0

        # Calculate XOFfset to center Price under Area {Nr}
        var XOffset:float=0.38
        if (Digits(0) <> 0.0). set XOffset = 0.31
        if (Digits(1) <> 0.0). set XOffset = 0.24
        if (Digits(2) <> 0.0). set XOffset = 0.17
        if (Digits(3) <> 0.0). set XOffset = 0.11
        if (DigitsAndSuffix(1) <> 0). set XOffset = 0.0
        set Material.XOffset = XOffset

    TestGetRandomInt<public>():void=
        Egg := EggDefinitions[0] or Err("")
       
        var Stats:[string]int = map{}

        Rarities := for (Reward : Egg.Rewards). Reward.Chance
        for (Idx := 0..10000):
            Winner := RollItem(Rarities, 1.0)
            Name := Egg.Rewards[Winner].Pet or ""
            if (not Stats[Name], set Stats[Name] = Winner) {}
            if. set Stats[Name] += 1

        for (K->V:Stats):
            Print("{K} rolled {V} ({(V*1.0/10000.0)*100}%) times.")
        
    RollEgg<public>(Guy:guy_module.guy, Egg:egg_definition)<transacts><decides>:pet_module.Service.pet_definition=
        Rarities := for (Reward : Egg.Rewards). Reward.Chance
        Winner := RollItem(Rarities, 1.0)
        Name := Egg.Rewards[Winner].Pet or ""
        GetGame().Pets.GetDefinitionFromName[Name]

    RollItem<public>(Options:[]float, Luck:float)<transacts>:int=
        Roll := GetRandomInt(0,100000)*1.0/100000.0

        var CumSum:float=0.0
        for (Idx := 0..Options.Length-1):
            Odds := 1.0 - Pow((1.0 - Options[Idx]), Luck) or 1.0
            set CumSum += Odds
            if (Roll <= CumSum):
                return Idx
        Options.Length-1

    # ftue helper
    GetClosestEggPurchasableLocation<public>(Guy:guy_module.guy, ?EggId:int=-1)<transacts><decides>:xyz_xform=
        var ClosestDist:float=9999999.9
        var ClosestXform:xyz_xform=xyz_xform{}
        
        if:
            Fort := Guy.Player.SafeFortCharacter[]
            FortPos := Fort.GetTransform()
        then:
            for (Egg:EggDefinitions, Egg.Id = EggId or EggId=-1, Position:Egg.Positions):
                DistanceBetween := FastDistance(Position.Translation, FortPos.Translation)
                if (DistanceBetween < ClosestDist):
                    set ClosestDist = DistanceBetween
                    set ClosestXform = Position
            
        ClosestXform

    # Define Eggs Here
    @editable EggDefinitions<public>:[]egg_definition = array {}