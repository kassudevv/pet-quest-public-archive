using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

anim_type := enum{Empty, Idle, Attack, Run}

pet_pawn_2<public> := class<unique>():
    # Pet Data (Type: Regular/Gold/Rainbow, Level: 1, etc)
    Data<public> : pet_module.Service.pet_definition

    # All Pets
    PetController<public> : controller

    var Prop : creative_prop = creative_prop{}

    TargetChanged:event()=event(){}
    var _TargetBreakable:?breakable_module.Service.breakable=false
    var LastAttackTime:float=0.0
    
    TargetToOwner():void=
        if (_TargetBreakable?):
            set _TargetBreakable = false
            TargetChanged.Signal()

    TargetToBreakable(B:breakable_module.Service.breakable, Position:vector3)<suspends>:void=            
        if (_TargetBreakable? = B). return

        set _TargetBreakable = option. B 
        TargetChanged.Signal()

        TargetTransform := B.Prop.GetTransform()

        race:
            block:
                MoveToBreakable(Position, TargetTransform.Translation)
                StartAttacking()
            TargetChanged.Await()
            OnDispose.Await()

    StartAttacking()<suspends>:void=
        if (B := _TargetBreakable?, Guy := PetController.Player.GetGuy[], PetService := GetGame().Pets):
            SetAnimation(anim_type.Attack)
            sync:
                loop:
                    GetGame().SFX.PlayRandomPunch(Prop.GetTransform().Translation)
                    Sleep(2.0)
                loop:
                    if (MegaMultiplier := Data.IsMega?.DamageMultiplierAsPercentOfBestPet):
                        B.Damage(Guy, ?AmountDamage := Guy.Pets.GetBestPetDamage()*MegaMultiplier, ?Quiet := true)
                    else:
                        B.Damage(Guy, ?AmountDamage := PetService.GetDamageFromLevel(Guy.Player, Data.Level), ?Quiet := true)
                    Sleep(1.0)
                loop:
                    B.WasDestroyed.Await()
                    set _TargetBreakable = false
                    TargetChanged.Signal()

    Init(Position : vector3):void=
        if:
            NewProp := SpawnProp(Data.Idle, Position, IdentityRotation())(0)?
            set Prop = NewProp

            Guy := PetController.Player.GetGuy[]
        then:
            Guy.Events.PetPawnAdded.Signal(Self)

    MoveSpeed:float= 800.0
    MoveTo(Position : vector3, LookTarget : vector3)<suspends>:void=
        if:
            Prop.IsValid[]
            StartTransform := Prop.GetTransform()

            # Create target transform
            var TargetTransform : transform = Prop.GetTransform()
            set TargetTransform.Translation = Position

            # Calculate Look Angle
            PropTransform := Prop.GetTransform().Translation
            LookTargetPosition := vector3{X:=Position.X, Y:=Position.Y, Z:=PropTransform.Z}

            LookDirection := (LookTargetPosition - PropTransform)
            Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
            Pitch := RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
            set TargetTransform.Rotation = MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, 0.0)

            # Is distance change large enough?
            DistanceBetween := FastDistance(StartTransform.Translation, TargetTransform.Translation)
            DistanceBetween >= 25.0

            RunLength := DistanceBetween/MoveSpeed
        then:
            # Start running animation
            SetAnimation(anim_type.Run)
            TargetChanged.Signal()

            race:
                block:
                    Prop.MoveTo(TargetTransform, 0.777)

                    # Wait 0.1s for another move command
                    Sleep(0.5)

                    # Set idle animation and look at final look target
                    SetAnimation(anim_type.Idle)
                    LookAt(LookTarget)
                TargetChanged.Await()

    MoveToBreakable(Position : vector3, LookTarget : vector3)<suspends>:void=
        if:
            Prop.IsValid[]
            StartTransform := Prop.GetTransform()

            # Create target transform
            var TargetTransform : transform = Prop.GetTransform()
            set TargetTransform.Translation = Position

            # Calculate Look Angle
            PropTransform := Prop.GetTransform().Translation
            LookTargetPosition := vector3{X:=Position.X, Y:=Position.Y, Z:=PropTransform.Z}

            LookDirection := (LookTargetPosition - PropTransform)
            Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
            Pitch := RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
            set TargetTransform.Rotation = MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, 0.0)

            # Is distance change large enough?
            DistanceBetween := FastDistance(StartTransform.Translation, TargetTransform.Translation)
            DistanceBetween >= 25.0

            var RunLength :float= DistanceBetween/MoveSpeed
        then:
            # Start running animation
            SetAnimation(anim_type.Run)
            
            if (RunLength > 2.0). set RunLength = 2.0
            Prop.MoveTo(TargetTransform, RunLength)

            # Wait 0.1s for another move command
            Sleep(GetRandomInt(0,20)*0.01)

            # Set idle animation and look at final look target
            SetAnimation(anim_type.Idle)
            LookAt(LookTarget, ?Duration := 0.1)

    # Set Pet Animation
    var CurrentAnim : anim_type = anim_type.Idle
    SetAnimation(Anim : anim_type):void=
        if:
            not IsDisposed?
            Prop.IsValid[]
            not CurrentAnim = Anim
        then:
            SpawnPosition := Prop.GetTransform()

            PropAsset := case(Anim):
                anim_type.Run => Data.Run
                anim_type.Idle => Data.Idle
                anim_type.Attack => Data.Attack
                _ => Data.Idle

            if (NewProp := SpawnProp(PropAsset, SpawnPosition)(0)?):
                Prop.Dispose()

                set CurrentAnim = Anim
                set Prop = NewProp

     # Look at target
    LookAt(Target : vector3, ?Instant : logic = false, ?Duration : float = 0.5)<suspends>:void=
        if:
            Prop.IsValid[]

            From := Prop.GetTransform().Translation
            NewTarget := vector3{X:=Target.X,Y:=Target.Y,Z:=From.Z}

            LookDirection := (NewTarget - From)
        then:
            Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X))
            Pitch := RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
            Rotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, 0.0)

            var NewTransform : transform = Prop.GetTransform()
            set NewTransform.Rotation = Rotation

            # Allow skipping animation
            if (Instant?, Prop.TeleportTo[NewTransform]) {}
            else {Prop.MoveTo(NewTransform, Duration)}

    var IsDisposed:logic=false
    OnDispose:event()=event(){}
    Dispose():void=
        set IsDisposed = true
        Prop.Dispose()
        OnDispose.Signal()
        if (Guy := PetController.Player.GetGuy[]). Guy.Events.PetPawnRemoved.Signal(Self)