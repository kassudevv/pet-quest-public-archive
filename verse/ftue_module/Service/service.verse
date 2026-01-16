using { /Fortnite.com/Devices }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }

objective<public> := class:
    Title<public>:string
    Description<public>:string
    TargetType<public>:string
    TargetAmount<public>:int
    TargetSpecifier<public>:int=-1
    RewardType<public>:string=""
    RewardAmount<public>:float=0.0

quest<public> := class:
    var Id<public>:int = -1
    Objective<public>:objective

service<public> := class(main_module.base_service):
    @editable var ObjectiveDevices<public>:[]objective_device = array{}

    var Quests:[int]quest = map:
        0 => quest:
            Objective :=  objective:
                Title := "Getting Started"
                Description := "Earn 150 gold"

                TargetType := "earn_gold"
                TargetAmount := 150

        1 => quest:
            Objective :=  objective:
                Title := "First Hatch"
                Description := "Hatch a Nature Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 0

        2 => quest:
            Objective :=  objective:
                Title := "Humble Miner"
                Description := "Earn 100 gold"

                TargetType := "earn_gold"
                TargetAmount := 100

        3 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 3 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 3

        4 => quest:
           Objective :=  objective:
                Title := "Gold Miner"
                Description := "Earn 200 gold"

                TargetType := "earn_gold"
                TargetAmount := 200

        5 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #2"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 1 # area 2

        6 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 1000 gold"

                TargetType := "earn_gold"
                TargetAmount := 1000

        7 => quest:
            Objective :=  objective:
                Title := "Better Pets"
                Description := "Hatch a Sphinx Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 1 # sphinx egg

        8 => quest:
            Objective :=  objective:
                Title := "Inventory Menu (Gold Remote)"
                Description := "Open your pet inventory"

                TargetType := "ftue_equip_pet"
                TargetAmount := 1

        9 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 4 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 4

        10 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 3000 gold"

                TargetType := "earn_gold"
                TargetAmount := 3000

        11 => quest:
            Objective :=  objective:
                Title := "Stronger Pets"
                Description := "Hatch 2 Sphinx Eggs"

                TargetType := "hatch_egg"
                TargetAmount := 2
                TargetSpecifier := 1 # sphinx egg

        12 => quest: # pyramid egg area
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #3"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 2

        13 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 5000 gold"

                TargetType := "earn_gold"
                TargetAmount := 3000

        14 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch a Pyramid Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 2

        15 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 10000 gold"

                TargetType := "earn_gold"
                TargetAmount := 10000

        16 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch 2 Pyramid Eggs"

                TargetType := "hatch_egg"
                TargetAmount := 2
                TargetSpecifier := 2

        17 => quest: # rock egg area
            Objective :=  objective:
                Title := "Icy Worlds"
                Description := "Unlock Area #4"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 3

        18 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 12000 gold"

                TargetType := "earn_gold"
                TargetAmount := 12000

        19 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch a Rock Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 3

        20 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 15000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 15000

        21 => quest:
            Objective :=  objective:
                Title := "New Area"
                Description := "Unlock Area #5"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 4

        22 => quest:
            Objective :=  objective:
                Title := "Teleport Menu (Purple Remote)"
                Description := "Open your Teleport Menu"

                TargetType := "ftue_teleport_spawn"
                TargetAmount := 1

        23 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 10000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 10000

        24 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch a Striped Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 4

        25 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 25 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 25

        26 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch 3 Striped Eggs"

                TargetType := "hatch_egg"
                TargetAmount := 3
                TargetSpecifier := 4

        27 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 25000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 25000

        28 => quest:
            Objective :=  objective:
                Title := "New Area"
                Description := "Unlock Area #6"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 5

        29 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 10 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 10

        30 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch 1 Wood Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 5

        31 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 35000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 35000

        32 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch 2 Wood Eggs"

                TargetType := "hatch_egg"
                TargetAmount := 2
                TargetSpecifier := 5

        33 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 10 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 10

        34 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 50000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 50000

        35 => quest:
            Objective :=  objective:
                Title := "New Area"
                Description := "Unlock Area #7"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 6

        36 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 50000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 50000

        37 => quest:
            Objective :=  objective:
                Title := "Hatch Pets"
                Description := "Hatch a Hive Egg"

                TargetType := "hatch_egg"
                TargetAmount := 1
                TargetSpecifier := 6

        38 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 50 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 50

        39 => quest:
            Objective :=  objective:
                Title := "It's Getting Hot..."
                Description := "Unlock Area #8"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 7
        40 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 100000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 100000
        41 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 50 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 50
        42 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #9"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 8
        43 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 200000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 200000
        44 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 25 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 25
        45 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #10"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 9
        46 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 500000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 500000
        47 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 50 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 50
        48 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #11"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 10
        49 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 100000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 100000
        50 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 100 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 100
        51 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #12"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 11
        52 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 250000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 250000
        53 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 25 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 25
        54 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #13"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 12
        55 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 500000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 500000
        56 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 75 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 75
        57 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #14"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 13
        58 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 1000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 1000000
        59 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 50 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 50
        60 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #15"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 14
        61 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 500000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 500000
        62 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 125 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 125
        63 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #16"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 15
        64 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 750000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 750000
        65 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 50 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 50
        66 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #17"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 16
        67 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 1500000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 1500000
        68 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 100 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 100
        69 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #18"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 17
        70 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 3000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 3000000
        71 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 200 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 200
        72 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #19"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 18
        73 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 5000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 5000000
        74 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 125 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 125
        75 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #20"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 19
        76 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 2500000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 2500000
        77 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 75 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 75
        78 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #21"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 20

        79 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 5000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 5000000
        80 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 125 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 125
        81 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #22"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 21
        82 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 3000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 3000000
        83 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 75 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 75
        84 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #23"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 22
        85 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 7500000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 7500000
        86 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 150 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 150
        87 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #24"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 23
        88 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 20000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 20000000
        89 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 100 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 100
        90 => quest:
            Objective :=  objective:
                Title := "New Areas"
                Description := "Unlock Area #25"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 24
        91 => quest:
            Objective :=  objective:
                Title := "Earn Gold"
                Description := "Earn 50000000 Gold"

                TargetType := "earn_gold"
                TargetAmount := 50000000
        92 => quest:
            Objective :=  objective:
                Title := "Break Breakables"
                Description := "Break 200 breakables"

                TargetType := "destroy_breakable"
                TargetAmount := 200
        93 => quest:
            Objective :=  objective:
                Title := "Rebirth 1!"
                Description := "Unlock Area #26"

                TargetType := "unlock_area"
                TargetAmount := 1
                TargetSpecifier := 25
        
        
                    
    Init<override>():void=
        Print("Load ftue service")
        for (Idx->Quest:Quests). set Quest.Id = Idx

    Get<public>(QuestId : int)<transacts><decides>:quest=Quests[QuestId]

    GetIcon<public>(TargetType:string, TargetSpecifier:int):texture=
        Game := GetGame()
        if (TargetType = "hatch_egg"). return if (not TargetSpecifier = -1) then. Game.Eggs.GetDefinition[TargetSpecifier].Icon or Assets.Models.Eggs.Icons.T_Egg_Basic else. Assets.Models.Eggs.Icons.T_Egg_Basic 
        if (TargetType = "earn_gold"). return Assets.UI.Icons.coinGold5
        if (TargetType = "destroy_breakable"). return Assets.UI.Icons.coin4
        if (TargetType = "ftue_equip_pet"). return Assets.UI.Icons.T_Remote
        if (TargetType = "unlock_area"). return Assets.UI.Icons.diamondgold5
        if (TargetType = "ftue_teleport_spawn"). return Assets.UI.Icons.T_Remotepurple
        return Assets.UI.Icons.T_exclamation

<#
☁️ WORLD 1 - LAUNCH UPDATE ☁️

🐶 Collect all 100+ Unique Pets! 🐶
🪙 Mine Gold to Unlock new Areas, Eggs & Pets! 🪙
🔥 Rebirth to Win MEGA Pets & Huge Bonuses!🔥
💎 Flex your rare Limited OP Pets! 💎

💾 100% Saving Enabled! 💾
⭐ Thanks for playing & have fun! ⭐


🪙 Mine Gold to Unlock new Areas, Eggs & Pets! 🪙
🐶 Collect all 100+ Unique Pets! 🐶
💎 Flex your rare Limited OP Pets! 💎
#>