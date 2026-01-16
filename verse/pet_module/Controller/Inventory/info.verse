using { /Fortnite.com/UI }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using {guy_module.user_interface_module}

info<public> := class:
    Player<public>:player
    
    HeaderWidget :Assets.UI.Inventory.WB_Pets_Headerbar= Assets.UI.Inventory.WB_Pets_Headerbar{}
    
    Refresh():void=
        if:
            Guy := Player.GetGuy[]
            MaxPetsEquipped := Guy.Inventory.Pets.GetPetEquipLimit()
        then:
            PetsEquipped:=Guy.Inventory.Pets.GetTotalPetsEquipped()

            set HeaderWidget.InfoText = text.Make("{PetsEquipped}/{MaxPetsEquipped}")

    # Pet Equipped/Unequipped
    OnPetStateUpdated(PetId:int):void=Refresh()

    Build<public>():widget=
        if:
            Guy := Player.GetGuy[]
        then:
            Guy.Events.PetEquipped.Subscribe(OnPetStateUpdated)
            Guy.Events.PetUnequipped.Subscribe(OnPetStateUpdated)

        set HeaderWidget.HeaderText = text.Make("Equipped Pets")
        
        Refresh()

        HeaderWidget

info_total_pets<public> := class:
    Player<public>:player
    
    HeaderWidget :Assets.UI.Inventory.WB_Pets_Headerbar= Assets.UI.Inventory.WB_Pets_Headerbar{}
    
    Refresh():void=
        if:
            Guy := Player.GetGuy[]
        then:
            Pets:=Guy.Inventory.Pets.GetTotalPets()

            set HeaderWidget.InfoText = text.Make("{Pets}")

    # Pet Equipped/Unequipped
    OnPetStateUpdated(PetId:int):void=Refresh()

    Build<public>():widget=
        if:
            Guy := Player.GetGuy[]
        then:
            Guy.Events.PetEquipped.Subscribe(OnPetStateUpdated)
            Guy.Events.PetUnequipped.Subscribe(OnPetStateUpdated)

        set HeaderWidget.HeaderText = text.Make("Total Pets")        
        
        Refresh()

        HeaderWidget