using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { utils_module }

breakable_type<public> := class<unique>():
    Tag<public>:tag

    # Max health of breakable
    MaxHealth<public>:float

    # Respawn cooldown in seconds
    Cooldown<public>:float = 3.0

    # How much gold to award in relation to damage
    GoldMultiplier<public>:float = 1.0

    # How far attacking pets are
    Radius<public>:float = 125.0
    
breakable_identifiers<public> := module:
    breakable_identifier := class(tag) {}

    # Basic Coins
    coin_1<public> := class(breakable_identifier){}
    coin_2<public> := class(breakable_identifier){}
    coin_3<public> := class(breakable_identifier){}
    coin_4<public> := class(breakable_identifier){}
    coin_5<public> := class(breakable_identifier){}
    coin_6<public> := class(breakable_identifier){}

    chest_desert<public> := class(breakable_identifier){}
    lblock<public> := class(breakable_identifier){}

breakable_definition<public> := class:
    Tag<public>:tag
    # Health of breakable
    MaxHealth<public>:float = 100.0
    # Gold to award = damage * (1.0 + GoldBonus + AreaBonus)
    GoldBonus<public>:float = 0.0
    # Respawn every (x..y) seconds
    RespawnCooldown<public>:float = 1.0
    # Seconds before first spawn
    InstantSpawnChance<public>:int=100 # range in percentage. 100 = 100%
    # How far should pets encircle
    AttackRadius<public>:float = 125.0
    # VFX location relative to prop
    EffectOffset<public>:vector3 = vector3{}
    HealthBarOffset<public>:vector3 = vector3{}
    HealthBarScale<public>:float = 1.0