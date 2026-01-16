using { /Verse.org/Simulation }

inventory_pets<public> := class():
    Player<public>:player

    GetEquippedPets<public>()<transacts><decides>:[]tuple(int, pet_data)=
        Guy := Player.GetGuy[]
        for (Id->Pet : Guy.Data.Pets, Pet.Equipped > 0). (Id, Pet)

    Has<public>(Id:int)<transacts><decides>:void=
        Guy := Player.GetGuyNoTransacts[]
        (for (PetId->Pet:Guy.Data.Pets, Pet.Owned>0, PetId=Id). Pet).Length > 0

    GetPetEquipLimit<public>()<transacts>:int=8
    GetTotalPetsEquipped<public>()<transacts>:int=
        if:
            Guy := Player.GetGuy[]
        then:
            var PetsEquipped:int=0
            for (Id->Pet:Guy.Data.Pets, Pet.Equipped > 0). set PetsEquipped += Pet.Equipped
            PetsEquipped
        else:
            0

    EquipBestPets<public>():void=
        if:
            Guy := Player.GetGuy[]
        then:
            for (Id->Pet:Guy.Data.Pets, Pet.Equipped > 0):
                for (Idx := 0..Pet.Equipped-1). Guy.Events.PetUnequipped.Signal(Id)
                Updated := pet_data{Owned := Pet.Owned, Equipped := 0}
                if. set Guy.Data.Pets[Id] = Updated
            if. Guy.Data.Save[]

            var PlayerPetsAsSortedArray : []tuple(int, pet_data) = for (Id -> Data : Guy.Data.Pets). (Id, Data)
            set PlayerPetsAsSortedArray = utils_module.MergeSort(for (Id -> Data : Guy.Data.Pets). (Id, Data), pet_module.Controller.Inventory.IsPetMorePowerfulThan)
            
            var PetsLeftToEquip:int = GetPetEquipLimit()
            for (PetTuple:PlayerPetsAsSortedArray, PetsLeftToEquip > 0, Id := PetTuple(0), Pet := PetTuple(1)):
                AmountEquipped := Min(PetsLeftToEquip, Pet.Owned)
                set PetsLeftToEquip -= AmountEquipped

                for (Idx := 0..AmountEquipped-1). Guy.Events.PetEquipped.Signal(Id)
                    
                Updated := pet_data{Owned := Pet.Owned, Equipped := AmountEquipped}
                if. set Guy.Data.Pets[Id] = Updated
            
            if. Guy.Data.Save[]

    GetTotalPets<public>()<transacts>:int=
        if:
            Guy := Player.GetGuy[]
        then:
            var PetsEquipped:int=0
            for (Id->Pet:Guy.Data.Pets). set PetsEquipped += Pet.Owned
            PetsEquipped
        else:
            0

    AwardPet<public>(Id:int, ?SkipAutoEquip:logic=false):void=
        if:
            Guy := Player.GetGuy[]
        then:
            if (Existing := Guy.Data.Pets[Id]):
                Updated := pet_data{Owned := Existing.Owned + 1, Equipped := Existing.Equipped}
                if (set Guy.Data.Pets[Id] = Updated, Guy.Data.Save[]) {}

                if:
                    Pet := GetGame().Pets.GetDefinition[Id]
                then:
                    spawn. Guy.UI.Notifications.PlayItem("Pet_{Id}", Pet.Icon, 1.0, ?NewItemText := "New Pet!")
            else:
                New := pet_data{Owned := 1, Equipped := 0}
                
                set Guy.Data.PetsDiscovered += array{Id}
                if (set Guy.Data.Pets[Id] = New, Guy.Data.Save[]) {}

                if:
                    Pet := GetGame().Pets.GetDefinition[Id]
                then:
                    spawn. Guy.UI.Notifications.PlayItem("Pet_{Id}", Pet.Icon, 1.0, ?NewItemText := "New Pet!")

            Guy.Events.PetAwarded.Signal(Id)

            if (not SkipAutoEquip?, GetTotalPetsEquipped() < GetPetEquipLimit()). spawn. DelayedEquipPet(Id)
            else. Guy.UI.GoldCounter.EnableNewPetHint()
            
    DelayedEquipPet<public>(Id:int)<suspends>:void=
        Sleep(0.0)
        EquipPet(Id)
    
    EquipPet<public>(Id:int):void=
         if:
            Guy := Player.GetGuy[]
            GetTotalPetsEquipped() < GetPetEquipLimit()
        then:
            if (Existing := Guy.Data.Pets[Id], Existing.Owned > Existing.Equipped):
                Updated := pet_data{Owned := Existing.Owned, Equipped := Existing.Equipped + 1}

                if (set Guy.Data.Pets[Id] = Updated, Guy.Data.Save[]):
                    Guy.Events.PetEquipped.Signal(Id)
            else:
                #Print("Couldn't equip pet.")

    UnequipPet<public>(Id:int):void=
        if:
            Guy := Player.GetGuy[]
        then:
            if (Existing := Guy.Data.Pets[Id], Existing.Equipped > 0):
                Updated := pet_data{Owned := Existing.Owned, Equipped := Existing.Equipped - 1}
                if (set Guy.Data.Pets[Id] = Updated, Guy.Data.Save[]):
                    Guy.Events.PetUnequipped.Signal(Id)
            else:
                #Print("Couldn't unequip pet?")

    Equip<public>(Id:int):void=
        if:
            Guy := Player.GetGuy[]
            # Player Has Pet
            Has[Id]
        then:
            # Equip New Pet & Save
            # set Guy.Data.EquippedPets += array{Id}
            if (Guy.Data.Save[]) {}

            # Print("Player has x{Guy.Data.EquippedPets.Length} equipped pets.")

    # util
    GetPowerStat<public>():float=
        if (Guy := Player.GetGuy[]):
            var PetPower:float=0.0
            BestPetDamage := Guy.Pets.GetBestPetDamage()
            PetService := GetGame().Pets
            for (Id->Data:Guy.Data.Pets, Data.Equipped > 0, Def := PetService.IdToPet[Id]):
                Damage := if (Mega := Def.IsMega?.DamageMultiplierAsPercentOfBestPet) then. BestPetDamage*Mega else. PetService.GetDamageFromLevel(Player, Def.Level) * 1.0
                set PetPower += Damage*Data.Equipped
            PetPower
        else:
            0.0
    GetTotalPowerStat<public>():float=
        if (Guy := Player.GetGuy[]):
            var TotalPetPower:float=0.0
            PetService := GetGame().Pets
            for (PetId->Data:Guy.Data.Pets, Data.Owned > 0, Def := PetService.IdToPet[PetId]):
                Damage := PetService.GetDamageFromLevel(Player, Def.Level) * 1.0
                set TotalPetPower += Damage*Data.Owned
            TotalPetPower
        else:
            0.0

inventory<public> := class(guy_extension):
    Pets<public> : inventory_pets

MakePlayerInventory<public><constructor>(Player:player) := inventory:
    Player := Player

    Pets := inventory_pets{Player := Player}
