using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }
using {guy_module.user_interface_module}

controller<public> := class(guy_module.guy_extension):
    var IsInAnimation<public>:logic=false # is player rolling an egg right now?

    Init<override>():void=
        Print("Init egg controller")

        if:
            Eggs := GetGame().Eggs
            Guy := Player.GetGuy[]
            Data := Guy.Data
            UnlockedAreas := Data.Areas
        then:
            Eggs.AutoHatchingToggle.SetState(Guy.Player, Guy.Data.AutoHatchEnabled)

    # Egg opening animation
    EggUnlockWidget:Assets.UI.ItemUnlock.WBP_EggOpening = Assets.UI.ItemUnlock.WBP_EggOpening{}
    PlayEggUnlockAnimationWithParams<public>(Egg:egg_module.Service.egg_definition, Pet:pet_module.Service.pet_definition, ?IsNew:logic=false)<suspends>:void=
        if (Player.IsActive[], PlayerUI := GetPlayerUI[Player]):
            set IsInAnimation = true
            defer. set IsInAnimation = false

            set EggUnlockWidget.EggIcon = Egg.Icon
            set EggUnlockWidget.PetIcon = Pet.Icon
            set EggUnlockWidget.PetName = text.Make(Pet.Name)
            NewText := text.Make("New!")
            set EggUnlockWidget.InfoText = IsNew? and NewText or text.Empty
            set EggUnlockWidget.RarityWidgetIndex = GetRarityLabelWidgetSwitcherIndex(Pet.Rarity)

            PlayerUI.AddWidget(EggUnlockWidget)
            set EggUnlockWidget.PlayAnim = 1.0
            Sleep(3.0)
            set EggUnlockWidget.PlayAnim = 0.0
            PlayerUI.RemoveWidget(EggUnlockWidget)

    GetRarityLabelWidgetSwitcherIndex<public>(Rarity:pet_module.Service.rarity):int=
        Rarities:[]pet_module.Service.rarity = array:
            pet_module.Service.rarity.Common,
            pet_module.Service.rarity.Rare,
            pet_module.Service.rarity.Epic,
            pet_module.Service.rarity.Legendary,
            pet_module.Service.rarity.Mythical,
            pet_module.Service.rarity.Gold,
            pet_module.Service.rarity.Rainbow
        return Rarities.Find[Rarity] or 0

MakeController<public><constructor>(Player:player) := controller:
    Player := Player