using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }

rarity<public> := enum{Common, Rare, Epic, Legendary, Mythical, Gold, Rainbow}

mega_pet_stats<public> := class<concrete>():
    @editable DamageMultiplierAsPercentOfBestPet<public>:float=1.0 # will always deal dmg*multiplier as much damage as best pet

pet_definition<public> := class<concrete>():
    @editable Id<public>:int = 0
    @editable Name<public> : string = "Unknown"

    @editable Level<public>:int = 1
    @editable Rarity<public>:rarity = rarity.Common
    
    @editable Icon<public>:texture = Assets.Models.Pets.Icons.T_Pet_Icon
    @editable Idle<public>:creative_prop_asset = DefaultCreativePropAsset
    @editable Run<public>:creative_prop_asset = DefaultCreativePropAsset
    @editable Attack<public>:creative_prop_asset = DefaultCreativePropAsset

    @editable IsMega<public>:?mega_pet_stats = false

service<public> := class(main_module.base_service):
    # Egg map (Id => Definition)
    var IdToPet<public>:[int]pet_definition = map{}
    var NameToPet<public>:[string]pet_definition = map{}

    Init<override>()<suspends>:void=
        for (Idx->Pet : PetDefinitions): 
            if. set IdToPet[Idx] = Pet
            if. set NameToPet[Pet.Name] = Pet
        
    GetDefinition<public>(Id:int)<transacts><decides>:pet_definition=
        if (not IdToPet[Id]). Print("IdToPet[{Id}] failed. Pet not found")
        IdToPet[Id]
    GetDefinitionFromName<public>(Name:string)<transacts><decides>:pet_definition=
        if (not NameToPet[Name]). Print("NameToPet[{Name}] failed. Pet not found")
        NameToPet[Name]
    IsValidPet<public>(Id:int)<transacts><decides>:void=GetDefinition[Id]

    # Damage = Level^0.95 + 1
    GetDamageFromLevel<public>(Player:player,Level:int):float=
        Base := 13.0
        var Constant:float = 1.0
        var Exponent:float= 1.45

        RebirthBoost := if (R := Player.GetGuy[].Data.Rebirths) then. (1.0 + R*0.2) else. 1.0
        Base+(Pow(Level*RebirthBoost*Constant, Exponent))

    @editable PetDefinitions<public>:[]pet_definition = array {}

    
    GetPetIconPath<public>(Name:string):texture=

        PetNameToTexture:[string]texture=map:
            "Cat" => Assets.Models.Pets.Icons.Icon05
            "Dog" => Assets.Models.Pets.Icons.Icon07
            "Butterfly" => Assets.Models.Pets.Icons.Icon04
            "Chick" => Assets.Models.Pets.Icons.Icon06
            "Duck" => Assets.Models.Pets.Icons.Icon08
            "Firefly" => Assets.Models.Pets.Icons.Icon09
            "Ladybug" => Assets.Models.Pets.Icons.Icon10
            "Mouse" => Assets.Models.Pets.Icons.Icon11
            "Squirrel" => Assets.Models.Pets.Icons.Icon12
            "Bunny" => Assets.Models.Pets.Icons.Icon13
            "Bee" => Assets.Models.Pets.Icons.Icon14
            "Chicken" => Assets.Models.Pets.Icons.Icon15
            "Froggy" => Assets.Models.Pets.Icons.Icon16
            "Lamb" => Assets.Models.Pets.Icons.Icon17
            "Turtle" => Assets.Models.Pets.Icons.Icon18
            "Parrot" => Assets.Models.Pets.Icons.Icon19
            "Piggy" => Assets.Models.Pets.Icons.Icon20
            "Pufferfish" => Assets.Models.Pets.Icons.Icon21
            "Raccoon" => Assets.Models.Pets.Icons.Icon22
            "Seal" => Assets.Models.Pets.Icons.Icon23
            "Cow" => Assets.Models.Pets.Icons.Icon24
            "Deer" => Assets.Models.Pets.Icons.Icon25
            "Fox" => Assets.Models.Pets.Icons.Icon26
            "Hedgehog" => Assets.Models.Pets.Icons.Icon27
            "Horse" => Assets.Models.Pets.Icons.Icon28
            "Llama" => Assets.Models.Pets.Icons.Icon29
            "Monkey" => Assets.Models.Pets.Icons.Icon30
            "Platypus" => Assets.Models.Pets.Icons.Icon31
            "Sloth" => Assets.Models.Pets.Icons.Icon32
            "Dalmatian Dog" => Assets.Models.Pets.Icons.Icon33
            "Black Bear" => Assets.Models.Pets.Icons.Icon34
            "Chimpanzee" => Assets.Models.Pets.Icons.Icon35
            "Dolphin" => Assets.Models.Pets.Icons.Icon40
            "Flamingo" => Assets.Models.Pets.Icons.Icon36
            "Jaguar" => Assets.Models.Pets.Icons.Icon37
            "Lion" => Assets.Models.Pets.Icons.Icon41
            "Panther" => Assets.Models.Pets.Icons.Icon38
            "Peacock" => Assets.Models.Pets.Icons.Icon42
            "Polar Bear" => Assets.Models.Pets.Icons.Icon39
            "Tiger" => Assets.Models.Pets.Icons.Icon43
            "Bat" => Assets.Models.Pets.Icons.Icon44
            "Cobra" => Assets.Models.Pets.Icons.Icon45
            "Cyclops" => Assets.Models.Pets.Icons.Icon46
            "Elephant" => Assets.Models.Pets.Icons.Icon47
            "Gorilla" => Assets.Models.Pets.Icons.Icon48
            "Hippo" => Assets.Models.Pets.Icons.Icon49
            "Mushroom" => Assets.Models.Pets.Icons.Icon50
            "Raven" => Assets.Models.Pets.Icons.Icon51
            "Rock" => Assets.Models.Pets.Icons.Icon53
            "Spidey" => Assets.Models.Pets.Icons.Icon54
            "Angel Cat" => Assets.Models.Pets.Icons.Icon55
            "Angel Dog" => Assets.Models.Pets.Icons.Icon59
            "Angel Lamb" => Assets.Models.Pets.Icons.Icon56
            "Devil" => Assets.Models.Pets.Icons.Icon57
            "Corgi Dog" => Assets.Models.Pets.Icons.Icon60
            "Griffin" => Assets.Models.Pets.Icons.Icon61
            "Nether Spider" => Assets.Models.Pets.Icons.Icon58
            "Pirate Monkey" => Assets.Models.Pets.Icons.Icon62
            "Shadow Cat" => Assets.Models.Pets.Icons.Icon63
            "Slime" => Assets.Models.Pets.Icons.Icon64
            "Dragon" => Assets.Models.Pets.Icons.Icon65
            "Shadow Cobra" => Assets.Models.Pets.Icons.Icon66
            "Shadow Dog" => Assets.Models.Pets.Icons.Icon67
            "Shadow Dragon" => Assets.Models.Pets.Icons.Icon68
            "MEGA Devil" => Assets.Models.Pets.Icons.Icon_MEGADevil

            "Miner Bunny" => Assets.Models.Pets.Icons.Icon69
            "Miner Cat" => Assets.Models.Pets.Icons.Icon70
            "Miner Chick" => Assets.Models.Pets.Icons.Icon71
            "Miner Dog" => Assets.Models.Pets.Icons.Icon72
            "MEGA Miner" => Assets.Models.Pets.Icons.Icon_MEGAMiner
            
            "MEGA Devil" => Assets.Models.Pets.Icons.Icon_MEGADevil
            "MEGA Dragon" => Assets.Models.Pets.Icons.T_MEGADragon
            "MEGA Slime" => Assets.Models.Pets.Icons.T_MEGASlime
            "MEGA Spidey" => Assets.Models.Pets.Icons.T_MEGASpidey

            "Cupcake" => Assets.Models.Pets.Icons.Icon73
            "Unicorn" => Assets.Models.Pets.Icons.Icon74

        if (not PetNameToTexture[Name]). Print("GetPetIconPath | Texture for Pet {Name} not found.")
        PetNameToTexture[Name] or Assets.Models.Pets.Icons.Icon07