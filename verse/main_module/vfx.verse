using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

vfx<public> := class<concrete>():
    @editable CoinExplosionCollectable<public>:creative_prop_asset = DefaultCreativePropAsset
    @editable CoinExplosionSmallCollectable<public>:creative_prop_asset = DefaultCreativePropAsset
    @editable ExplosionShockwave<public>:creative_prop_asset = DefaultCreativePropAsset

    @editable CoinExplosion:creative_prop_asset = DefaultCreativePropAsset
    @editable CoinExplosionSmall:creative_prop_asset = DefaultCreativePropAsset

    @editable CoinImpact<public>:creative_prop_asset = DefaultCreativePropAsset  
    @editable CoinImpactHeavy<public>:creative_prop_asset = DefaultCreativePropAsset  

    Play<public>(Player:player, T:transform):void=
        if:
            Fort := Player.SafeFortCharacter[]
            FortEntity := Fort.GetEntity[]
            
            ParticleEntity := entity{}
            ParticleEffect : Assets.VFX.CoinExplosion.NS_ExplosionShockwave = Assets.VFX.CoinExplosion.NS_ExplosionShockwave{Entity := ParticleEntity, AutoPlay := true}
            SimulationEntity := GetGame().GetSimulationEntity[]
        then:
            FixedTransform:luf_xform = luf_xform{Translation := luf_vec3{Left:=0.0,Up:=0.0,Forward:=0.0}, Rotation := luf_rotation{}}
            ParticleEntity.AddComponents(array{ParticleEffect})

            # ParticleEntity.SetGlobalTransform(T.ToLUF())
            FortEntity.AddEntities(array{ParticleEntity})
            ParticleEffect.Enable()
            ParticleEffect.Play()

            spawn. TestVisibility(ParticleEntity, Player)

    TestVisibility(Entity:entity, Player:player)<suspends>:void=
        Sleep(0.5)
        Entity.SetPresentableToPlayers(option. array{})
        Sleep(0.5)
        Entity.SetPresentableToPlayers(option. array{Player})
        Sleep(0.5)
        Entity.SetPresentableToPlayers(option. array{})
        Sleep(0.5)
        Entity.SetPresentableToPlayers(option. array{Player})

    @editable CriticalHit:creative_prop_asset = DefaultCreativePropAsset
    @editable BonusHit:creative_prop_asset = DefaultCreativePropAsset
    PlayCriticalHit<public>(Position:vector3):void=
        if:
            SpawnedProp := SpawnProp(CriticalHit, Position, rotation{})(0)?
        then:
            spawn {SpawnedProp.DelayedDispose(3.0)}

    PlayBonusHit<public>(Position:vector3):void=
        if:
            SpawnedProp := SpawnProp(BonusHit, Position, rotation{})(0)?
        then:
            spawn {SpawnedProp.DelayedDispose(3.0)}