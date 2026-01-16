using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { breakable_module }
using { breakable_module.Service }
using { device_identifier_tags }
using { guy_module }
using { utils_module }

controller<public> := class(guy_extension):
    PetService<public>:pet_module.Service.service

    var Props:[]creative_prop = array{}
    var Pets<public> : []pet_pawn_2 = array{}

    var CurrentArea:?area_module.Service.breakable_area=false

    Init<override>():void=
        # LoadPets()
        Print("Init pet controller.")

        if:
            Guy := Player.GetGuy[]
        then:
            for (Id->PetData:Guy.Data.Pets, Pet := GetGame().Pets.GetDefinition[Id], PetData.Equipped>0):
                for (Idx:=0..PetData.Equipped-1):
                    Pawn := pet_pawn_2 {PetController := Self, Data := Pet}
                    set Pets += array. Pawn

            Guy.Events.PetEquipped.Subscribe(OnPetEquipped)
            Guy.Events.PetUnequipped.Subscribe(OnPetUnequipped)
        spawn {Start()}

    Dispose<override>():void=
        for (Pet:Pets). Pet.Dispose()

    #? Pet Load, Equip, Unequip
    OnPetUnequipped(Id:int):void=
        for (Pet : Pets, Pet.Data.Id = Id):
            set Pets = for (V : Pets, V <> Pet). V
            Pet.Dispose()
            return

    OnPetEquipped(Id:int):void=
        if (Pet := GetGame().Pets.GetDefinition[Id]):
            Pawn := pet_pawn_2 {PetController := Self, Data := Pet}
            set Pets += array. Pawn

    RetargetAllPetsToOwner():void=
        for (Pet:Pets). Pet.TargetToOwner()

    RetargetAllPetsToBreakable(Breakable:breakable_module.Service.breakable):void=
        TargetTransform := Breakable.Prop.GetTransform()
        PetPositions := GetCirclePositions(TargetTransform.Translation, Breakable.Definition.AttackRadius, Pets.Length)
        for (Idx->Pet:Pets, Pos := PetPositions[Idx]):
            if (not Pet.Prop.IsValid[]):
                Pet.Init(Pos)
                spawn. Pet.LookAt(Breakable.Prop.GetTransform().Translation, ?Instant := true)
            else:
                spawn. Pet.TargetToBreakable(Breakable, Pos)

    var PlayerTargetBreakable : ?breakable = false
    Start()<suspends>:void=
        if:
            Guy := Player.GetGuy[] 
        then:
            sync:
                loop:
                    if (Breakable := PlayerTargetBreakable?):
                        RetargetAllPetsToBreakable(Breakable)
                    else if (not CurrentArea?). RetargetAllPetsToOwner()
                    Sleep(0.1)
                loop:
                    set PlayerTargetBreakable = Guy.Events.TargetedBreakable.Await()
                loop:
                    set CurrentArea = Guy.Events.CurrentAreaChanged.Await()
                    if (not CurrentArea?, not PlayerTargetBreakable?). RetargetAllPetsToOwner()
                loop:
                    if (Area := CurrentArea?, not PlayerTargetBreakable?):
                        for (Index->Pet:Pets):
                            if (Target := Pet._TargetBreakable?, Target.Active?):
                                # Print("Pet has target already, skipping")                                    
                            else:
                                # Print("Pet does not have target, assigning")
                                if (RB:=Area.GetRandomBreakable[]):
                                    Transform := RB.Prop.GetTransform()
                                    PetPositions := GetCirclePositions(Transform.Translation, RB.Definition.AttackRadius, 16)
                                    if (PetPosition := PetPositions[GetRandomInt(0,15)]):
                                        if (not Pet.Prop.IsValid[]):
                                            Pet.Init(PetPosition)
                                            spawn. Pet.LookAt(Transform.Translation, ?Instant := true)
                                            spawn. Pet.TargetToBreakable(RB, PetPosition)
                                        else:
                                            spawn. Pet.TargetToBreakable(RB, PetPosition)
                    Sleep(1.0)
                loop:
                    # Position pets behind the player
                    if:
                        not PlayerTargetBreakable?
                        not CurrentArea?

                        Fort := Player.SafeFortCharacter[]
                        Transform := Fort.GetTransform()
                        ForwardVector := Transform.Rotation.GetLocalForward()
                        LeftVector := Transform.Rotation.GetLocalRight() * -1.0

                        # 168.0 to go from the player to the ground
                        var Translation : vector3 = Transform.Translation
                        set Translation.Z -= 168.0/2.0

                        # Cap Z axis at 8.0 to avoid going underground
                        set Translation.Z = Max(Translation.Z, -32.0)
                    then:
                        PetPositions := GetVectorPositions(Translation, ForwardVector, LeftVector, Pets.Length, 100.0, 75.0)

                        for (Index->Pet : Pets, Position := PetPositions[Index]):
                            # Pet doesn't have a prop, do spawning animation
                            if (not Pet.Prop.IsValid[]):
                                Pet.Init(Position)
                            # Pet has prop, move to new location
                            else:
                                spawn {Pet.MoveTo(Position, Translation)}

                    Sleep(1.0)


    #? Utility
    GetPetDamage<public>(Pet:pet_pawn_2):float=
        PetService.GetDamageFromLevel(Player, Pet.Data.Level) * 1.0

    GetBestPetDamage<public>():float=
        var BestPetDamage:float = 30.0

        if (Guy := Player.GetGuy[]):
            for (Id->Data:Guy.Data.Pets, Data.Equipped > 0, Def := PetService.IdToPet[Id]):
                Damage := PetService.GetDamageFromLevel(Player, Def.Level) * 1.0
                set BestPetDamage = Max(BestPetDamage, Damage)

        BestPetDamage

    GetPickaxeDamage<public>():float=
        if (Guy:=Player.GetGuy[]):
            var BestPetDamage:float=30.0
            for (Id->PetData : Guy.Data.Pets, Pet := PetService.GetDefinition[Id]):
                Damage := PetService.GetDamageFromLevel(Player, Pet.Level) * 1.0
                set BestPetDamage = Max(Damage, BestPetDamage)
            return BestPetDamage
        else. return 30.0

MakePlayerPetController<public><constructor>(Player:player) := controller:
    Player := Player
    PetService := GetGame().Pets

# Helper function to calculate positions with left and right offsets
# n = number of pets
# d = dist from player
# s = spacing between pets
GetVectorPositions(StartPosition:vector3, ForwardVector:vector3, LeftVector:vector3, n:int, d:float, s:float):[]vector3=
    var Positions:[]vector3 = array{}

    # Calculate positions in a curved formation
    for (Index := 0..n - 1):
        # Center pet will be at the full distance `d`, while side pets will be slightly closer
        DistanceFactor := Pow(Abs(Index * 1.0 - (n * 1.0 - 1.0) / 2.0), 2.0) / Pow(n * 1.0 / 2.0, 2.0)
        DistanceFromPlayer := d * (1.0 - 0.35 * DistanceFactor)  # Reduces distance for side pets

        # Calculate the offset for each position
        LateralOffset := (Index * 1.0 - (n * 1.0 - 1.0) / 2.0) * s
        OffsetPosition := StartPosition + (ForwardVector * -DistanceFromPlayer) + (LeftVector * LateralOffset)

        # Add the position to the list
        set Positions = Positions + array{OffsetPosition}

    return Positions

# Returns a list of pet positions arranged in multiple rows behind the player
GetMultiRowVectorPositions(StartPosition:vector3, ForwardVector:vector3, LeftVector:vector3, n:int, petsPerRow:int, spacingBetweenPets:float, spacingBetweenRows:float):[]vector3=
    var Positions:[]vector3 = array{}
    var TotalRows:int = Ceil((n + petsPerRow - 1) / petsPerRow) or 1  # ceil division

    for (RowIndex := 0..TotalRows - 1):
        # Determine how many pets in this row
        RowStart := RowIndex * petsPerRow
        RowCount := Min(petsPerRow, n - RowStart)

        # For each pet in this row, calculate position
        for (i := 0..RowCount - 1):
            PetIndex := RowStart + i

            # Curved distance logic (optional for aesthetic)
            DistanceFactor := Pow(Abs(i * 1.0 - (RowCount * 1.0 - 1.0) / 2.0), 2.0) / Pow(RowCount * 1.0 / 2.0, 2.0)
            DistanceFromPlayer := spacingBetweenRows * (RowIndex + 1) * (1.0 - 0.35 * DistanceFactor)

            # Lateral offset centered around the middle
            LateralOffset := (i * 1.0 - (RowCount * 1.0 - 1.0) / 2.0) * spacingBetweenPets

            Position := StartPosition + (ForwardVector * -DistanceFromPlayer) + (LeftVector * LateralOffset)
            set Positions += array{Position}

    return Positions

# Helper function to calculate `n` positions around a circle centered on `CenterPosition`
GetCirclePositions(CenterPosition:vector3, Radius:float, n:int):[]vector3=
    var Positions : []vector3 = array{}
    var AngleIncrement : float = (2 * PiFloat) / (n * 1.0)  # Angle between each position in radians

    for (Index := 0..n - 1):
        # Calculate the angle for the current position
        Angle := Index * AngleIncrement

        # Calculate the offset using cosine and sine for circular distribution
        OffsetX := Radius * Cos(Angle)
        OffsetY := Radius * Sin(Angle)

        # Calculate the position and add it to the array
        CirclePosition := CenterPosition + vector3{X:= OffsetX, Y:=OffsetY, Z:=0.0}
        set Positions = Positions + array{CirclePosition}

    return Positions