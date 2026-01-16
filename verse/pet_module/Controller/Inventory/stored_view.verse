using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { EventModule }
using { pet_module.Service }
using { utils_module }
using { guy_module }
using { guy_module.user_interface_module }

stored_pet_box<public> := class<unique>():
    Guy<public>:guy
    Maid:maid = maid{}

    # Pet definition data
    Pet<public>:pet_definition
    # Background box based on rarity
    RarityIdx<public>:int
    # Parent used for removing pet box
    var Parent<public>:stack_box
    StoredView<public>:stored_view
    var Row<public>:int
    
    # Player persistence data regarding pet
    var Data<public>:pet_data

    var Container:overlay = overlay{}
    var Content:stack_box = stack_box{Orientation := orientation.Vertical}

    var LevelInfoTextBlock:text_block = text_block{}
    var AmountInfoTextBlock:text_block = text_block{}

    var EquipButton:button_quiet = button_quiet{}

    var PetWidget:?Assets.UI.DarkUI.WB_Pet=false

    # ftue helper
    EnableHint<public>():void=if (W := PetWidget?). set W.IsHintVisible = true

    GetAmountText():message=
        Amount := Data.Owned - Data.Equipped
        Amount <= 1 and text.Empty or text.Make("x{Amount.Format()}")

    RefreshInfo():void=
        if:
            NewData := Guy.Data.Pets[Pet.Id]
            set Data = NewData
        then:
            if (PW := PetWidget?):
                set PW.Count = GetAmountText()

            Amount := Data.Owned - Data.Equipped

            # Less than 0 left in stock, remove button!
            if (Amount <= 0). spawn. Remove()
                
    OnEquip(WM : widget_message):void=
        if (Guy.Inventory.Pets.GetTotalPetsEquipped() >= Guy.Inventory.Pets.GetPetEquipLimit()). return GetGame().SFX.Error.Play(Guy.Player)

        Guy.Inventory.Pets.EquipPet(Pet.Id)

        GetGame().SFX.InventoryShuffle.Play(Guy.Player)
        RefreshInfo()

    Remove()<suspends>:void=
        Sleep(0.0)
        EquipButton.SetEnabled(false)

        Sleep(0.1)

        Self.Dispose()

        # If this Box is in the top row, shift the first bottom row box up to the top row. 
        if (Row = 0, FirstBottomBox := StoredView.BottomBoxes[0]):
            FirstBottomBox.MoveToTopRow()

        StoredView.TryFillBottomRow()

    MoveToTopRow():void=
        if (Index := StoredView.BottomBoxes.Find[Self], NewBottomRow := StoredView.BottomBoxes.RemoveElement[Index]):
            Parent.RemoveWidget of Container
            StoredView.TopRow.AddWidget of stack_box_slot:
                Padding := margin{Left:=8.0}
                Widget := Container
            
            set Parent = StoredView.TopRow
            set Row = 0

            set StoredView.TopBoxes += array{Self}
            set StoredView.BottomBoxes = NewBottomRow

    Dispose():void=
        Maid.Cleanup()

        Parent.RemoveWidget of Container

        if (Row = 0). set StoredView.TopBoxes = for (Box : StoredView.TopBoxes, Box <> Self). Box
        if (Row = 1). set StoredView.BottomBoxes = for (Box : StoredView.BottomBoxes, Box <> Self). Box

    GetVariationIdx():int=
        if (Pet.Rarity = rarity.Gold). return 1
        if (Pet.Rarity = rarity.Rainbow). return 2
        0
        
    Build():overlay=
        Amount := Data.Owned - Data.Equipped

        # Info text
        set LevelInfoTextBlock = text_block{DefaultText := text.Make("{Pet.Level}"), DefaultTextSize := 48.0, DefaultTextColor := NamedColors.White, DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}, DefaultShadowColor := NamedColors.Black, DefaultShadowOpacity := 1.0}
        set AmountInfoTextBlock = text_block{DefaultText := GetAmountText(), DefaultTextSize := 32.0, DefaultTextColor := NamedColors.White, DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}, DefaultShadowColor := NamedColors.Black, DefaultShadowOpacity := 1.0}
        
        # Buttons
        set EquipButton = button_quiet{DefaultText := text.Empty}
        Maid.AddCancelable(EquipButton.OnClick().Subscribe(OnEquip))

        RefreshInfo()

        MegaText := text.Make("???")

        WBPet := Assets.UI.DarkUI.WB_Pet:
            RarityIdx := RarityIdx
            VariationIdx := GetVariationIdx()
            
            Icon := Pet.Icon
            Level := Pet.IsMega? and MegaText or text.Make("{Pet.Level.Format()}")
            Count := GetAmountText()
        set PetWidget = option. WBPet

        set Container = overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=140.0,Y:=140.0}}
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := EquipButton

                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding := margin{Top:=-2160.0}
                    Widget := WBPet

        Container

stored_view<public> := class<unique>():
    Player<public>:player

    var Widget<public>:stack_box=stack_box{Orientation:=orientation.Vertical}

    var TopRow<public>:stack_box=stack_box{Orientation:=orientation.Horizontal}
    var BottomRow<public>:stack_box=stack_box{Orientation:=orientation.Horizontal}

    var TopBoxes<public>:[]stored_pet_box = array{}
    var BottomBoxes<public>:[]stored_pet_box = array{}

    TryFillBottomRow():void=
        # Max 7 visible per row
        TotalVisible := TopBoxes.Length + BottomBoxes.Length

        if (TotalVisible >= 14):
            return

        if:
            Guy := Player.GetGuy[]
            PetInventory := Guy.UI.PetInventory
            PetService := GetGame().Pets
        then:
            PetInventory.LoadAllValidStoredPets()

            for (PetTuple : PetInventory.StoredPets, Id := PetTuple(0), Data := PetTuple(1), Pet := PetService.GetDefinition[Id], BottomBoxes.Length < 7):
                var AlreadyExists:logic=false
                for (PetBox : BottomBoxes, PetBox.Pet.Id = Id). set AlreadyExists = true
                for (PetBox : TopBoxes, PetBox.Pet.Id = Id). set AlreadyExists = true

                if (not AlreadyExists?):
                    # Create pet box for in bottom row
                    Box := stored_pet_box:
                        Row := 1
                        Parent := BottomRow
                        StoredView := Self

                        RarityIdx := Guy.Eggs.GetRarityLabelWidgetSwitcherIndex(Pet.Rarity)

                        Guy := Guy
                        Pet := Pet
                        Data := Data

                    BottomRow.AddWidget of stack_box_slot:
                        Padding := margin{Left:=BottomBoxes.Length = 0 and 0.0 or 8.0}
                        Widget := Box.Build()

                    set BottomBoxes += array{Box}

    Build<public>(PetInventory:pet_inventory):widget=        
        # properly clean up existing boxes
        for (Box : TopBoxes). Box.Dispose()
        for (Box : BottomBoxes). Box.Dispose()

        set TopBoxes = array{}
        set BottomBoxes = array{}

        # clean up rows
        Widget.RemoveWidget of TopRow
        Widget.RemoveWidget of BottomRow

        set Widget = stack_box{Orientation := orientation.Vertical}

        # build boxes
        if:
            Guy := Player.GetGuy[]
            PetService := GetGame().Pets   
        then:
            set TopRow = stack_box{Orientation:=orientation.Horizontal}
            set BottomRow = stack_box{Orientation:=orientation.Horizontal}

            var IsFirst:logic = true

            var Index:int = 0

            for:
                Idx->PetTuple : PetInventory.StoredPets
                Id := PetTuple(0)
                Data := PetTuple(1)
            do:
                if:
                    Pet := PetService.GetDefinition[Id]
                then:
                    Row := Index < 7 and TopRow or BottomRow

                    if (Index = 7). set IsFirst = true

                    Box := stored_pet_box:
                        Row := Index < 7 and 0 or 1
                        Parent := Row
                        StoredView := Self

                        RarityIdx := Guy.Eggs.GetRarityLabelWidgetSwitcherIndex(Pet.Rarity)

                        Guy := Guy
                        Pet := Pet
                        Data := Data

                    if (Index < 7). set TopBoxes += array{Box} else. set BottomBoxes += array{Box}
                    
                    Row.AddWidget of stack_box_slot:
                        Padding := margin{Left:=IsFirst? and 0.0 or 8.0}
                        Widget := Box.Build()

                    set IsFirst = false
                    set Index += 1
                else:
                    Print("Stored View | Index {Index} - skipping invalid Pet Id: {Id}")

        Widget.AddWidget of stack_box_slot:
            Widget := TopRow

        Widget.AddWidget of stack_box_slot:
            Padding := margin{Top:=8.0}
            Widget := BottomRow

        Widget

            