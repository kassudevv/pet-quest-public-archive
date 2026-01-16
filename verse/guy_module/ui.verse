using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }
using { user_interface_module }

ui<public> := class(guy_extension):
    HealthBar<public>:health_bar

    Currency<public>:currency
    GoldCounter<public>:gold_counter
    Leaderboard<public>:leaderboard

    PetInventory<public>:pet_module.Controller.Inventory.pet_inventory
    Codes<public>:reward_module.Controller.codes
    Notifications<public>:user_interface_module.notifications
    BackgroundSunburst<public>:background_sunburst
    BackgroundBlur<public>:background_blur
    Teleports<public>:teleports
    Rebirths<public>:rebirths
    Stats<public>:stats
    Menu<public>:menu
    
    # Ftue
    StarterPetDialog<public>:ftue_module.Controller.user_interface_module.pick_starter_pet
    Quests<public>:ftue_module.Controller.user_interface_module.quests_ui

    UniversalCanvas<public>:canvas = canvas{}

    Init<override>():void=
        if (Player.IsActive[], PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(UniversalCanvas)

        # Set up gold counter
        if (Guy := Player.GetGuy[]):
            Guy.Maid.Add(Guy.Events.ResourceChanged.Subscribe(OnResourceChanged))
            GoldCounter.SetValue(Guy.Data.Gold)
            GoldCounter.Enable()

            Leaderboard.Enable()

        Notifications.Build()

    # if resource is gold
    OnResourceChanged(Type:resource_type, Value:float):void=
        if (Type = resource_type.Gold). GoldCounter.SetValue(Value)
             
MakePlayerUI<public><constructor>(Player:player) := ui:
    Player := Player

    HealthBar := health_bar{Player := Player}
    
    PetInventory := pet_module.Controller.Inventory.MakePetInventory(Player)
    Codes := reward_module.Controller.MakeCodesUI(Player)
    Notifications := user_interface_module.MakeItemNotifications(Player)
    
    Currency := currency{Player := Player}

    BackgroundSunburst := background_sunburst{Player := Player}
    BackgroundBlur := background_blur{Player := Player}
    GoldCounter := gold_counter{Player := Player}
    Leaderboard := leaderboard{Player := Player}
    StarterPetDialog := ftue_module.Controller.user_interface_module.MakeStarterPetUI(Player)
    Quests := ftue_module.Controller.user_interface_module.MakeQuestsUI(Player)

    Teleports := MakeTeleportsUI(Player)
    Rebirths := MakeRebirthsUI(Player)
    Stats := MakeStatsUI(Player)
    Menu := MakeMenuUI(Player)