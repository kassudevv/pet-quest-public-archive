using { /Fortnite.com/Devices }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

coin_sounds<public> := class<concrete>():
    @editable Small<public>:audio_player_device = audio_player_device{}
    @editable Medium<public>:audio_player_device = audio_player_device{}
    @editable Large<public>:audio_player_device = audio_player_device{}

sfx<public> := class<concrete>():
    @editable PunchSounds:[]creative_prop_asset = array{}
    @editable ExplosionSounds:[]creative_prop_asset = array{}

    @editable CoinSounds<public>:coin_sounds = coin_sounds{}

    @editable Error<public>:audio_player_device = audio_player_device{}
    @editable Success<public>:audio_player_device = audio_player_device{}

    @editable InventoryOpen<public>:audio_player_device = audio_player_device{}
    @editable InventoryShuffle<public>:audio_player_device = audio_player_device{}

    @editable MagicShockwave<public>:creative_prop_asset = DefaultCreativePropAsset

    @editable Notification<public>:audio_player_device = audio_player_device{}
    @editable Bonus<public>:audio_player_device = audio_player_device{}
    @editable Bubble<public>:audio_player_device = audio_player_device{}
    
    @editable AreaUnlock<public>:audio_player_device = audio_player_device{}
    @editable GroundBreaking<public>:audio_player_device = audio_player_device{}
    @editable QuestCompleted<public>:audio_player_device = audio_player_device{}
    
    @editable UnlockRarePet<public>:audio_player_device = audio_player_device{}  
    @editable UnlockGoodPet<public>:audio_player_device = audio_player_device{}  

    @editable Soundtracks<public>:[]audio_player_device = array{}  

    PlayMagicShockwave<public>(Position:vector3):void=
        if:
            SpawnedProp := SpawnProp(MagicShockwave, Position, rotation{})(0)?
        then:
            spawn {SpawnedProp.DelayedDispose(5.0)}

    PlayRandomPunch<public>(Position:vector3):void=
        if:
            RandomPunchSFX := PunchSounds[GetRandomInt(0, PunchSounds.Length - 1)]
            SpawnedProp := SpawnProp(RandomPunchSFX, Position, rotation{})(0)?
        then:
            spawn {SpawnedProp.DelayedDispose(5.0)}

    PlayRandomExplosion<public>(Position:vector3):void=
        if:
            RandomPunchSFX := ExplosionSounds[0]
            SpawnedProp := SpawnProp(RandomPunchSFX, Position, rotation{})(0)?
        then:
            spawn {SpawnedProp.DelayedDispose(5.0)} 