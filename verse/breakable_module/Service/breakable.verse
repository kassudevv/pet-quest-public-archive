using { /Fortnite.com/Devices }
using { /Fortnite.com/Devices/CreativeAnimation }
using { /Fortnite.com/Devices/CreativeAnimation/InterpolationTypes }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { EventModule }
using { utils_module }

animation_type<public> := enum{Hit, Destroy}

breakable<public> := class<unique>():
    Area<public>:area_module.Service.breakable_area
    
    Definition<public>:breakable_definition
    Prop<public>:creative_prop

    # Variables
    var Health<public>:float = 0.0
    MaxHealth<public>:float
    var Active<public>:logic = false

    # Internal
    var InitialTransform<public>:transform = transform{}

    # Events
    HealthChanged<public>:signal(float) = signal(float){}
    WasDestroyed<public>:event() = event(){}

    Init<public>():void=
        set Health = MaxHealth
        set Active = true

        set InitialTransform = Prop.GetTransform()

        if (Definition.InstantSpawnChance < 100):
            ShouldSpawn := logic{GetRandomInt(1,100) <= Definition.InstantSpawnChance}
            if (not ShouldSpawn?). spawn. DoSpawnHide()

        spawn. TrackHealthBar()

    TrackHealthBar()<suspends>:void=
        loop:
            HealthChanged.Await()
            spawn. UpdateHealthBar()

    var CurrentHealthBar:?health_bar=false
    UpdateHealthBar()<suspends>:void=
        if (Health = 0.0, HB := CurrentHealthBar?):
            GetGame().Breakables.HealthBarPool.Free(HB)
            set CurrentHealthBar = false
            return
        race:
            block:
                if (HB := CurrentHealthBar?):
                    HB.SetValue(Health, Health/MaxHealth)
                else:
                    SpawnPos := InitialTransform.Translation + vector3{Z:=150.0} + Definition.HealthBarOffset
                    HB := GetGame().Breakables.HealthBarPool.Spawn(SpawnPos, Health, Health/MaxHealth, Definition.HealthBarScale)
                    set CurrentHealthBar = option. HB
                Sleep(5.0)
                if (HB := CurrentHealthBar?):
                    GetGame().Breakables.HealthBarPool.Free(HB)
                set CurrentHealthBar = false                
            HealthChanged.Await()
    
    GetGoldFromDamage(Guy:guy_module.guy, AmountDamage:float)<transacts>:float=
        RebirthBonus := Guy.Data.Rebirths*0.2
        AmountDamage * (1.0 + Definition.GoldBonus + Area.GoldBonus + RebirthBonus)

    Damage<public>(Guy : guy_module.guy, ?AmountDamage:float = 1.0, ?Quiet:logic=false):void=
        if (not Active?). return
        GameService := GetGame()
        
        # 1/3 chance of bonus with gap of 4-5 hits between each.
        IsBonus := logic{not Quiet? and Guy.Breakables.LastBonusHitsAgo >= 4 and GetRandomInt(1, 3) = 1} 
        IsUltraBonus := logic{not Quiet? and Guy.Breakables.LastBonusHitsAgo >= 4 and GetRandomInt(1, 15) = 1} 
        
        var BaseDamage:float=AmountDamage
        if (IsUltraBonus?). set BaseDamage *= 2.0 else if (IsBonus?). set BaseDamage *= 1.5
        var CappedDamage:float = Min(BaseDamage, MaxHealth/2.9)

        set Health = Max(Health - CappedDamage, 0.0)
        HealthChanged.Signal(Health)

        GoldFromHit:= GetGoldFromDamage(Guy, CappedDamage)*(GetRandomInt(40,60)*0.01)
        
        # Play destroy hit, award extra 33% coins.
        IsDestroyed := logic{Health <= 0.0}
        if (IsDestroyed?). return OnDestroyed(Guy, GoldFromHit)

        # Don't run effects on Pet Hit, just award GoldFromHit with a small chance of bonus coins.
        if (Quiet?):                
            if (GetRandomInt(1,5)=1):
                GameService.Breakables.Coins.SpawnCoinSmall(InitialTransform.Translation + vector3{X := GetRandomFloat(-50.0,50.0), Y := GetRandomFloat(-50.0,50.0), Z:=GetRandomFloat(25.0,50.0)}, GoldFromHit, Guy)
                if (SpawnedProp := SpawnProp(GameService.VFX.CoinImpactHeavy, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
                    spawn. SpawnedProp.DelayedDispose(2.0)
            else:
                if (SpawnedProp := SpawnProp(GameService.VFX.CoinImpact, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
                    spawn. SpawnedProp.DelayedDispose(2.0)
            return Guy.Resources.Award(guy_module.resource_type.Gold, Max(GoldFromHit, 1.0))

        # Play bonus hit, awarding 3x coins, or ultra bonus hit awarding 14x coins.
        if (IsUltraBonus?). return OnUltraBonusHit(Guy, GoldFromHit)
        if (IsBonus?). return OnBonusHit(Guy, GoldFromHit)

        return OnNormalHit(Guy, GoldFromHit)
                
    # Award Gold From Hit + 1/3 of MaxHealth. 
    OnDestroyed(InstigatingGuy : guy_module.guy, GoldToAward:float):void=
        spawn {Destroy(InstigatingGuy)}
        InstigatingGuy.Events.BreakableDestroyed.Signal()
        
        GameService := GetGame()

        DestroyGoldBonus := GetGoldFromDamage(InstigatingGuy, MaxHealth*0.1)
        InstigatingGuy.Resources.Award(guy_module.resource_type.Gold, DestroyGoldBonus)
        GameService.SFX.CoinSounds.Medium.Play(InstigatingGuy.Player)

        CoinSpawnPosition := InitialTransform.Translation + vector3{X := GetRandomFloat(-50.0,50.0), Y := GetRandomFloat(-50.0,50.0), Z:=GetRandomFloat(25.0,50.0)}
        GameService.Breakables.Coins.SpawnCoin(CoinSpawnPosition, DestroyGoldBonus, InstigatingGuy)
        
        GameService.SFX.PlayMagicShockwave(InitialTransform.Translation + Definition.EffectOffset)
        if (ShockwaveProp := SpawnProp(GameService.VFX.ExplosionShockwave, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. ShockwaveProp.DelayedDispose(5.0)

        if (SpawnedProp := SpawnProp(GameService.VFX.CoinImpactHeavy, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. SpawnedProp.DelayedDispose(2.0)

        WasDestroyed.Signal()

    # Award Gold From Damage 5x. Once with Award, twice with Coins.
    OnUltraBonusHit(InstigatingGuy : guy_module.guy, GoldToAward:float):void=
        Print("Ultra Bonus!")
        set InstigatingGuy.Breakables.LastBonusHitsAgo = 0

        GameService := GetGame()

        GameService.VFX.PlayBonusHit(InitialTransform.Translation + Definition.EffectOffset + vector3{Z:=128.0})

        GameService.Analytics.HitUltraBonus.Award(InstigatingGuy.Player)

        GameService.SFX.PlayMagicShockwave(InitialTransform.Translation + Definition.EffectOffset)
        if (ShockwaveProp := SpawnProp(GameService.VFX.ExplosionShockwave, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. ShockwaveProp.DelayedDispose(5.0)

        InstigatingGuy.Resources.Award(guy_module.resource_type.Gold, GoldToAward*(GetRandomInt(30,40)*0.1))
        GameService.SFX.CoinSounds.Medium.Play(InstigatingGuy.Player)

        CoinSpawnPosition := InitialTransform.Translation + vector3{X := GetRandomFloat(-50.0,50.0), Y := GetRandomFloat(-50.0,50.0), Z:=GetRandomFloat(25.0,50.0)}
        GameService.Breakables.Coins.SpawnCoin(CoinSpawnPosition, GoldToAward*(GetRandomInt(40,70)*0.1), InstigatingGuy)

        if (SpawnedProp := SpawnProp(GameService.VFX.CoinImpactHeavy, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. SpawnedProp.DelayedDispose(2.0)

    # Award Gold From Damage 3x. Once with Award, twice with Coins.
    OnBonusHit(InstigatingGuy : guy_module.guy, GoldToAward:float):void=
        set InstigatingGuy.Breakables.LastBonusHitsAgo = 0

        GameService := GetGame()

        GameService.Analytics.HitBonus.Award(InstigatingGuy.Player)

        GameService.VFX.PlayCriticalHit(InitialTransform.Translation + Definition.EffectOffset + vector3{Z:=128.0})
        
        InstigatingGuy.Resources.Award(guy_module.resource_type.Gold, GoldToAward)
        GameService.SFX.CoinSounds.Small.Play(InstigatingGuy.Player)

        CoinSpawnPosition := InitialTransform.Translation + vector3{X := GetRandomFloat(-50.0,50.0), Y := GetRandomFloat(-50.0,50.0), Z:=GetRandomFloat(25.0,50.0)}
        GameService.Breakables.Coins.SpawnCoinMedium(CoinSpawnPosition, GoldToAward*(GetRandomInt(20,40)*0.1), InstigatingGuy)
        
        GameService.SFX.PlayMagicShockwave(InitialTransform.Translation + Definition.EffectOffset + vector3{Z:=64.0})
        if (ShockwaveProp := SpawnProp(GameService.VFX.ExplosionShockwave, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. ShockwaveProp.DelayedDispose(5.0)

        if (SpawnedProp := SpawnProp(GameService.VFX.CoinImpact, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. SpawnedProp.DelayedDispose(2.0)

    # Award Gold From Damage 1x. Half with Award, half with Coins.
    OnNormalHit(InstigatingGuy : guy_module.guy, GoldToAward:float):void=
        set InstigatingGuy.Breakables.LastBonusHitsAgo += 1

        GameService := GetGame()

        GoldFromHitHalf := GoldToAward*0.5

        GameService.Analytics.Hit.Award(InstigatingGuy.Player)

        InstigatingGuy.Resources.Award(guy_module.resource_type.Gold, Max(GoldFromHitHalf, 1.0))
        # GameService.SFX.CoinSounds.Small.Play(InstigatingGuy.Player)

        CoinSpawnPosition := InitialTransform.Translation + vector3{X := GetRandomFloat(-50.0,50.0), Y := GetRandomFloat(-50.0,50.0), Z:=GetRandomFloat(25.0,50.0)}
        GameService.Breakables.Coins.SpawnCoinSmall(CoinSpawnPosition, GoldFromHitHalf, InstigatingGuy)

        if (SpawnedProp := SpawnProp(GameService.VFX.CoinImpact, InitialTransform.Translation + Definition.EffectOffset, rotation{})(0)?):
            spawn. SpawnedProp.DelayedDispose(2.0)

    Destroy(InstigatingGuy : guy_module.guy)<suspends>:void=
        set Active = false

        GameService := GetGame()

        # SFX/VFX
        GameService.SFX.PlayRandomExplosion(InitialTransform.Translation)

        # Animate Down
        Animate(animation_type.Destroy)

        # Hide Prop
        var NewPosition : transform = InitialTransform
        set NewPosition.Translation = NewPosition.Translation - vector3{X := 0.0, Y := 0.0, Z:= 1000.0}
        if (Prop.TeleportTo[NewPosition]) {}

        # Wait for Respawn Cooldown
        Sleep(Definition.RespawnCooldown)

        # BACK IN BUSINESS!
        Reset()

    DoSpawnHide()<suspends>:void=
        set Active = false
        var NewPosition : transform = InitialTransform
        set NewPosition.Translation = NewPosition.Translation - vector3{X := 0.0, Y := 0.0, Z:= 1000.0}
        if (Prop.TeleportTo[NewPosition]) {}
        Sleep(Definition.RespawnCooldown)
        Reset()

    Reset():void=
        if (Prop.TeleportTo[InitialTransform]) {}

        set Health = MaxHealth
        set Active = true

    # Animation Utility
    OnAnimate:event() = event(){}
    Animate<public>(AnimationType:animation_type)<suspends>:void=
        OnAnimate.Signal()

        race:
            block:
                if:
                    AnimController := Prop.GetAnimationController[]
                    Prop.TeleportTo[InitialTransform]
                then:
                    MovementKeyframe : keyframe_delta = keyframe_delta{
                                DeltaLocation := vector3{X:=0.0, Y:=0.0, Z:=20.0}
                                DeltaRotation := MakeRotationFromYawPitchRollDegrees(0.0, 0.0, 0.0)
                                DeltaScale := vector3{X:=0.01, Y:=0.01, Z:=0.01}
                                Time := 0.2
                                Interpolation := EaseInOut
                            }

                    AnimController.SetAnimation(array{MovementKeyframe}, ?Mode:=animation_mode.OneShot)
                    AnimController.Play()
                    AnimController.MovementCompleteEvent.Await()
                    AnimController.Stop()
            OnAnimate.Await()