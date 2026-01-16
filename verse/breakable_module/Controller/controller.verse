using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { guy_module }
using { utils_module }

# Handles breakable targeting
tracking_result := enum{TargetChanged}

breakable_controller<public> := class(guy_extension):    
    # How many hits ago did the player last get bonus?
    var LastBonusHitsAgo<public>:int=0

    # Current breakable
    var TargetedBreakable:?Service.breakable = false

    Init<override>():void=
        Print("Init breakable controller")
        spawn. ListenForCoins()
        
    ListenForCoins()<suspends>:void=
        if:
            Guy := Player.GetGuy[]
            SpatialGrid := GetGame().Breakables.SpatialGrid
        then:
            loop:
                if:
                    Fort := Guy.Player.SafeFortCharacter[]
                    Position := Fort.GetTransform().Translation
                then:
                    Coins := SpatialGrid.GetCoinsInRadius(Position, 1500.0)
                    for (Coin : Coins, Coin.Owner = Guy, not Coin.Collected?, Coin.Active?):
                        spawn. Coin.Collect()
                Sleep(0.0)

    #* Player was detected damaging something withn prop manipulator
    #? Search for target, deal damage and start targeting. 
    OnActivatedPropManipulatorDamagedEvent<public>(Area:area_module.Service.breakable_area):void=
        if:
            Guy := Player.GetGuy[]
            Fort := Player.SafeFortCharacter[]

            Breakables := Area.Breakables
            var ClosestBreakable : Service.breakable = Breakables[0]
            var ClosestAngle : float = Pow(2.0, 31.0)
            var ClosestDist : float = Pow(2.0, 31.0)
        then:
            FortTransform:=Fort.GetTransform()
            FortTranslation:=FortTransform.Translation-vector3{Z:=64.0}
            for (Breakable : Breakables, Breakable.Active?):
                if:
                    Dist := Distance(Breakable.InitialTransform.Translation, FortTranslation)
                    Dist < 2000.0

                    ToTranslation : vector3 = Breakable.InitialTransform.Translation
                    ViewingDirection := (ToTranslation - FortTranslation).MakeUnitVector[]
                    FromForwardVector := FortTransform.Rotation.GetLocalForward()
                    Dot := DotProduct(FromForwardVector, ViewingDirection)
                    Angle := RadiansToDegrees(ArcCos(Dot))

                    Angle < 65.0
                    Dist < ClosestDist
                then:
                    set ClosestAngle = Angle
                    set ClosestBreakable = Breakable
                    set ClosestDist = Dist

            # Looking at very close breakable?
            if (ClosestDist < 2000.0):
                Guy.Breakables.Target(ClosestBreakable)

                ClosestBreakable.Damage(Guy, ?AmountDamage := Guy.Pets.GetPickaxeDamage())

    # Start Targeting Breakable (Pets will attack it!)
    OnPickaxed<private>:event()=event(){}
    Target<public>(Breakable:Service.breakable):void=
        if:
            Guy := Player.GetGuy[]
        then:
            if:
                not TargetedBreakable? or TargetedBreakable? <> Breakable
            then:
                # Targeted Breakable Changed
                set TargetedBreakable = option { Breakable }
                Guy.Events.TargetedBreakable.Signal(TargetedBreakable)

                spawn {TrackTarget()}
            else if (TargetedBreakable? = Breakable):
                OnPickaxed.Signal()

    # Track breakable health and deal damage
    TrackTarget()<suspends>:void=
        if:
            Guy := Player.GetGuy[]
            Breakable := TargetedBreakable?
        then:
            var LastChange:float = GetSimulationElapsedTime()

            race:
                loop:
                    LastHitDelta := LastChange.GetDeltaTime()

                    # Haven't hit for 4 seconds!
                    if (LastHitDelta >= 4.0):
                        set TargetedBreakable = false
                        Guy.Events.TargetedBreakable.Signal(TargetedBreakable)
                        return

                    Sleep(0.1)
                loop:
                    Health := Breakable.HealthChanged.Await()

                    # Health is less than 0!
                    if (Health <= 0.0):
                        set TargetedBreakable = false
                        Guy.Events.TargetedBreakable.Signal(TargetedBreakable)
                        return

                loop:
                    OnPickaxed.Await()
                    set LastChange = GetSimulationElapsedTime()
                Guy.Events.TargetedBreakable.Await()
                Guy.Events.Left.Await()

MakePlayerBreakables<public><constructor>(Player:player) := breakable_controller:
    Player := Player