using { /Fortnite.com/Devices }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

health_bar<public> := class<unique>:
    var Material:?Assets.UI.HealthBar.M_HB_World=false
    
    var _Prop<public>:?creative_prop=false
    var Position<public>:vector3=vector3{}
    var Value<public>:float=0.0
    var Progress<public>:float=1.0
    var Size<public>:float=1.0

    Build():health_bar=
        PropAsset := GetGame().Areas.HealthBarPropAsset
        SpawnTransform :transform=transform{Translation:= Position, Rotation := rotation{}}
        if (HBProp := SpawnProp(PropAsset, SpawnTransform)(0)?):
            set _Prop = option. HBProp
            M := Assets.UI.HealthBar.M_HB_World{}
            set Material = option. M
            set M.Scale = Size
            HBProp.SetMaterial(M)
            UpdateMaterial()
        return Self

    SetPosition(InPos:vector3):void=
        set Position = InPos

        SpawnTransform :transform=transform{Translation:= Position, Rotation := rotation{}}
        if (_Prop?.TeleportTo[SpawnTransform]) {}

    SetValue(Health:float, InProgress:float):void=
        set Value = Health
        set Progress = InProgress
        UpdateMaterial()
    SetSize(InSize:float):void=
        set Size = InSize 
        if (M := Material?). set M.Scale = Size

    UpdateMaterial():void=
        # Normalized Price (e.g. 1420*10^3 -> 1.42*10^6)
        var ValueAsBigNum:big_number = big_number{Value := Value * 1.0, Exponent := 0}.Normalize()
        Normalized := ValueAsBigNum.NormalizeToNearestNumberSet()
        # Stringified Price (e.g. "1.42M")
        Stringified := ValueAsBigNum.Format()
        # What index location to place the dot at
        DotPosition : float = "{Stringified[1]}" = "." and 1.0 or "{Stringified[2]}" = "." and 2.0 or 0.0
        DigitsAndSuffix := area_module.Service.FormatBigNumberWithSuffixSeparate(ValueAsBigNum)
        Digits := area_module.Service.EncodeStringIntoDigits(DigitsAndSuffix(0))

        if (M := Material?):
            set M.Digit1 = Digits(0)
            set M.Digit2 = Digits(1)
            set M.Digit3 = Digits(2)
            set M.Digit4 = Digits(3)
            set M.SuffixIndex = DigitsAndSuffix(1) * 1.0
            set M.Progress = Lerp(0.12,0.88,Progress)

            # Calculate XOFfset to center Price under Area {Nr}
            var XOffset:float=0.19
            if (Digits(0) <> 0.0). set XOffset = 0.19
            if (Digits(1) <> 0.0). set XOffset = 0.15
            if (Digits(2) <> 0.0). set XOffset = 0.1
            if (Digits(3) <> 0.0). set XOffset = 0.07
            if (DigitsAndSuffix(1) <> 0). set XOffset = 0.0
            set M.XOffset = XOffset

health_bar_pool<public> := class:
    var AvailableHealthBars<public>:[]health_bar = array{}

    Spawn(SpawnPos:vector3, InitialValue:float, InitialProgress:float, Scale:float):health_bar=
        if (HB := AvailableHealthBars[AvailableHealthBars.Length - 1]):
            set AvailableHealthBars = for (AHB:AvailableHealthBars, AHB<>HB). AHB
            HB.SetPosition(SpawnPos)
            HB.SetValue(InitialValue,InitialProgress)
            HB.SetSize(Scale)
            HB
        else:
            health_bar{Position:=SpawnPos,Value:=InitialValue, Progress:=InitialProgress, Size:=Scale}.Build()

    Free(HB:health_bar):void=
        if (Prop := HB._Prop?, Prop.IsValid[]):
            var T:transform = Prop.GetTransform()
            set T.Translation = T.Translation - vector3{Z:=2000.0}
            if. Prop.TeleportTo[T]
        set AvailableHealthBars += array{HB}

service<public> := class(main_module.base_service):
    Coins:coins=coins{}
    SpatialGrid<public>:spatial_grid = spatial_grid{}
    
    var Breakables<public>:[]breakable = array{}
    var HitDetectors:[]prop_manipulator_device = array{}
    var HealthBarPool<public>:health_bar_pool = health_bar_pool{}

    # Initialize breakables and start area hit detector
    Start<override>():void=
        Areas := GetGame().Areas.Areas

        var AreaToPropManipulatorMap:[area_module.Service.breakable_area]tuple(prop_manipulator_device,vector3) = map{}
        for (Area:Areas, not Area.HitDetector.IsNullPosition[]):
            if. set AreaToPropManipulatorMap[Area] = (Area.HitDetector, Area.HitDetector.GetTransform().Translation)

        var BreakableCounter:[int]int = map{}

        Print("{BreakableDefinitions2.Length} definitions detected")
        for (Type:BreakableDefinitions2):
            PropsOfType := GetBreakablePropsOfType(Type.Tag)
            for (Prop:PropsOfType):
                Translation := Prop.GetTransform().Translation
                for (Area->HitDetector:AreaToPropManipulatorMap):
                    DistanceToHitDetector := FastDistance(HitDetector(1), Translation)

                    if (IsBreakableInsideHitDetector[Translation.X,Translation.Y,HitDetector(1).X,HitDetector(1).Y]):
                        Area.InitBreakable(Prop)
                        if (not BreakableCounter[Area.Id], set BreakableCounter[Area.Id] = 0) {}
                        if (Current := BreakableCounter[Area.Id], set BreakableCounter[Area.Id] = Current + 1) {}

        # for (AreaId->Count : BreakableCounter):
        #     Print("Area {AreaId} has {Count} breakables.")

    IsBreakableInsideHitDetector(posX:float, posY:float, centerX:float, centerY:float)<transacts><decides>:void=
        Abs(posX-centerX) <= 1200.0
        Abs(posY-centerY) <= 1200.0

    GetDefinition<public>(TagView:tag_view)<transacts><decides>:breakable_definition=
        Found := for (Definition : BreakableDefinitions2, TagView.Has[Definition.Tag]). Definition
        Found[0]

    # Get breakable being looked at and do damage
    OnBreakableHit(Agent : agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            #Guy.Breakables.OnActivatedPropManipulatorDamagedEvent()

    GetBreakablePropsOfType<public>(Tag:tag):[]creative_prop=
        BreakableProp := FindCreativeObjectsWithTag(Tag)
        for (Object : BreakableProp, Prop := creative_prop[Object]). Prop

    BreakableDefinitions2<public>:[]breakable_definition = array:
        breakable_definition:
            Tag := breakable_identifiers.coin_1{}
            MaxHealth := 25.0
            GoldBonus := 0.0
            RespawnCooldown := 6.0
            AttackRadius := 125.0
            InstantSpawnChance := 70
        breakable_definition:
            Tag := breakable_identifiers.coin_2{}
            MaxHealth := 74.0
            GoldBonus := 0.2
            RespawnCooldown := 10.0
            AttackRadius := 150.0
            InstantSpawnChance := 70
        breakable_definition:
            Tag := breakable_identifiers.coin_3{}
            MaxHealth := 135.0
            GoldBonus := 0.35
            RespawnCooldown := 30.0
            AttackRadius := 175.0
            InstantSpawnChance := 70
        breakable_definition:
            Tag := breakable_identifiers.coin_4{}
            MaxHealth := 200.0
            GoldBonus := 0.3
            RespawnCooldown := 25.0
            AttackRadius := 175.0
            InstantSpawnChance := 70
        breakable_definition:
            Tag := breakable_identifiers.coin_5{}
            MaxHealth := 285.0
            GoldBonus := 0.25
            RespawnCooldown := 15.0
            AttackRadius := 175.0
            EffectOffset := vector3{Z:=64.0}
            InstantSpawnChance := 70
        breakable_definition:
            Tag := breakable_identifiers.coin_6{}
            MaxHealth := 240.0
            GoldBonus := 0.2
            RespawnCooldown := 15.0
            AttackRadius := 125.0
            EffectOffset := vector3{Z:=64.0}
            InstantSpawnChance := 70
        breakable_definition:
            Tag := breakable_identifiers.chest_desert{}
            MaxHealth := 1500.0
            GoldBonus := 0.5
            RespawnCooldown := 600.0
            AttackRadius := 200.0
            HealthBarOffset := vector3{Z:=16.0}
            EffectOffset := vector3{Z:=64.0}
            HealthBarScale := 1.5
            InstantSpawnChance := 30
        breakable_definition:
            Tag := breakable_identifiers.lblock{}
            MaxHealth := 100.0
            GoldBonus := 5.0
            RespawnCooldown := 120.0
            AttackRadius := 125.0
            HealthBarOffset := vector3{Z:=16.0}
            EffectOffset := vector3{Z:=32.0}
            HealthBarScale := 1.25
            InstantSpawnChance := 75

IsWithinBoundsXY(Position:vector3, StartPosition:vector3, EndPosition:vector3)<transacts><decides>:void=
    MinX := Min(StartPosition.X, EndPosition.X)
    MaxX := Max(StartPosition.X, EndPosition.X)

    MinY := Min(StartPosition.Y, EndPosition.Y)
    MaxY := Max(StartPosition.Y, EndPosition.Y)

    Position.X >= MinX and Position.X <= MaxX
    Position.Y >= MinY and Position.Y <= MaxY