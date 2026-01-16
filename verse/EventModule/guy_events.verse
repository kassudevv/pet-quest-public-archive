using { verse.main_module }
using { verse.utils_module }
using { verse.breakable_module }

guy_events<public> := class:
    # Player loaded in for the first time or left the game
    Joined<public>:signal(verse.guy_module.guy) = signal(verse.guy_module.guy){}
    Left<public>:signal(verse.guy_module.guy) = signal(verse.guy_module.guy){}

    # On spawned, On player died
    Spawned<public>:signal(tuple()) = signal(tuple()){} #unimpl
    Died<public>:signal(tuple()) = signal(tuple()){} #unimpl

    # Player resource changed (e.g. Gold, Rebirths, Gems)
    ResourceChanged<public>:signal(tuple(verse.guy_module.resource_type, float)) = signal(tuple(verse.guy_module.resource_type, float)){}
    
    # Breakable actions
    TargetedBreakable<public>:signal(?verse.breakable_module.Service.breakable) = signal(?verse.breakable_module.Service.breakable){}
    StoppedTargetingBreakable<public>:event() = event(){}

    # Pet actions all unimpl
    PetEquipped<public>:signal(int) = signal(int){}
    PetUnequipped<public>:signal(int) = signal(int){}
    PetPawnAdded<public>:signal(pet_module.Controller.pet_pawn_2)=signal(pet_module.Controller.pet_pawn_2){}
    PetPawnRemoved<public>:signal(pet_module.Controller.pet_pawn_2)=signal(pet_module.Controller.pet_pawn_2){}
    
    PetAwarded<public>:signal(int) = signal(int){}
    PetRemoved<public>:signal(int) = signal(int){}
    
    # Areas
    AreaUnlocked<public>:signal(int) = signal(int){}
    CurrentAreaChanged<public>:signal(?area_module.Service.breakable_area) = signal(?area_module.Service.breakable_area){}
    Rebirthed<public>:signal(tuple())=signal(tuple()){}
    
    PetUnlocked<public>:signal(int) = signal(int){}
    EggHatched<public>:signal(int) = signal(int){}
    GoldAwarded<public>:signal(float)=signal(float){}
    BreakableDestroyed<public>:signal(tuple())=signal(tuple()){}