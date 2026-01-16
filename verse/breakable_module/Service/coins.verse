using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Assets }
using { /Verse.org/Random }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

collectable_item<public> := class<unique>():
    var Active<public>:logic=true
    var Collected<public>:logic=true

    Owner<public>:guy_module.guy
    AmountCoins<public>:float

    Delay:float=0.75
    Timeout:float=60.0

    SpawnPosition<public>:vector3
    Sound<public>:audio_player_device
    # Particle<public>:entity

    Award():void=
        Sound.Play(Owner.Player)    
        Owner.Resources.Award(guy_module.resource_type.Gold, AmountCoins)

    var Prop:creative_prop = creative_prop{}

    var GridFlatVec:tuple(int,int) = (0,0)

    var ParticleEntity:entity = entity{}

    Init():void=
        if:
            SimulationEntity := GetGame().GetSimulationEntity[]
            SpatialGrid := GetGame().Breakables.SpatialGrid
        then:
            set GridFlatVec = SpatialGrid.RegisterCoin(Self)

            ParticleEntity.SetGlobalTransform(luf_xform{Translation := SpawnPosition.ToLUF()})
            ParticleEntity.SetPresentableToPlayers(option. array{Owner.Player})
            SimulationEntity.AddEntities(array{ParticleEntity})

            spawn. ListenForTimeout()
            spawn. EnableAfterDelay()

    EnableAfterDelay()<suspends>:void=
        Sleep(Delay)
        set Collected = false

    Collect<public>()<suspends>:void=
        if (Active?, not Collected?, Fort := Owner.Player.SafeFortCharacter[]):
            ParticleEntity.SetGlobalTransform(Fort.GetTransform().ToLUF())
            set Collected = true
            Sleep(0.5)
            Award()
            Dispose()

    ListenForTimeout()<suspends>:void=
        defer:
            Dispose()
        
        race:
            block:
                Sleep(Timeout)
            Owner.Events.Left.Await()
        
    Dispose():void=
        if (not Active?). return
        set Active = false

        Game := GetGame()
        SpatialGrid := Game.Breakables.SpatialGrid
        SpatialGrid.RemoveCoin(GridFlatVec, Self)

        ParticleEntity.RemoveFromParent()

coins<public> := class(main_module.base_service):
    SpawnCoin(At:vector3, AmountCoins:float, Owner:guy_module.guy):void=
        Coin := collectable_item:
            Owner := Owner
            SpawnPosition := At
            AmountCoins := AmountCoins
            Sound := GetGame().SFX.CoinSounds.Large

        ParticleEffect : Assets.VFX.CoinExplosion.NS_CoinExplosion_Collect = Assets.VFX.CoinExplosion.NS_CoinExplosion_Collect{Entity := Coin.ParticleEntity}
        Coin.ParticleEntity.AddComponents of array. ParticleEffect

        Coin.Init()

    SpawnCoinMedium(At:vector3, AmountCoins:float, Owner:guy_module.guy):void=
        Coin := collectable_item:
            Owner := Owner
            SpawnPosition := At
            AmountCoins := AmountCoins
            Sound := GetGame().SFX.CoinSounds.Medium

        ParticleEffect : Assets.VFX.CoinExplosion.NS_CoinExplosion_Collect = Assets.VFX.CoinExplosion.NS_CoinExplosion_Collect{Entity := Coin.ParticleEntity}
        Coin.ParticleEntity.AddComponents of array. ParticleEffect

        Coin.Init()

    SpawnCoinSmall(At:vector3, AmountCoins:float, Owner:guy_module.guy):void=
        Coin := collectable_item:
            Owner := Owner
            SpawnPosition := At
            AmountCoins := AmountCoins
            Sound := GetGame().SFX.CoinSounds.Small

        ParticleEffect : Assets.VFX.CoinExplosion.NS_CoinExplosionSmall_Collect = Assets.VFX.CoinExplosion.NS_CoinExplosionSmall_Collect{Entity := Coin.ParticleEntity}
        Coin.ParticleEntity.AddComponents of array. ParticleEffect

        Coin.Init()
