using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { utils_module }
using { guy_module }
using { guy_module.user_interface_module }

controls<public> := class<unique>():
    Player<public>:player

    InfoTextBlock:text_block = text_block{DefaultText := text.Empty, DefaultTextColor := NamedColors.White}

    Build():overlay=
        InfoTextBlock.SetText(text.Make("1 / 1"))
        BackPageButton := button_quiet{DefaultText := text.Make("◀")}
        NextPageButton := button_quiet{DefaultText := text.Make("▶")}

        overlay:
            Slots := array:
                # bg
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Widget := Assets.UI.DarkUI.Containers.WB_Container_Blue{}

                # buttons
                overlay_slot:
                    Padding := margin{Left:=8.0,Right:=8.0,Top:=8.0,Bottom:=8.0}    
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Center
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := array:
                            # left
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget := BackPageButton

                            # page text
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Padding := Margin(8,0)
                                Widget := InfoTextBlock

                            # right
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget := NextPageButton

pet_inventory<public> := class(user_interface):
    Interactive<override>:logic = true

    BlurBackground<override>:logic = true

    Sunburst<override>:logic = true
    SunburstSize<override>:float = 3500.0

    Controls<public>:pet_controls
    Paginator<public>:pets_paginator

    #? Pet View variable definitions
    EquippedView<public>:equipped_view
    var EquippedPetsList:?widget = false
    EquippedPetsContainer:overlay = overlay{}

    StoredView<public>:stored_view
    var StoredPetsList:?widget = false
    StoredPetsContainer:overlay = overlay{}

    var StoredPets:[]tuple(int, pet_data) = array{}

    LoadAllValidStoredPets():void=
        if (Guy := Player.GetGuy[], PetService := GetGame().Pets):
            # Filter only valid & stored pets. Organize into simpler data structure
            for (Pet:Guy.Data.Pets):
            set StoredPets = for (Id -> Data : Guy.Data.Pets, PetService.IsValidPet[Id], (Data.Owned - Data.Equipped) > 0). (Id, Data)

            # Sort & paginate for current page
            set StoredPets = Paginator.Paginate(utils_module.MergeSort(StoredPets, IsPetMorePowerfulThan))

    #? Pet View refresh methods
    UpdateStoredPetView():void=
        # Update Pet Display
        if (Existing := StoredPetsList?) {StoredPetsContainer.RemoveWidget(Existing)}

        if:
            Guy := Player.GetGuy[]
            PetService := GetGame().Pets
        then:
            LoadAllValidStoredPets()

            var Widget:widget = StoredView.Build(Self)
            StoredPetsContainer.AddWidget of overlay_slot {Widget := Widget}
            set StoredPetsList = option. Widget

        if:
            InfoHeaderTotalPets := _InfoHeaderTotalPets?
        then:
            InfoHeaderTotalPets.Refresh()

    UpdateEquippedPetView():void=
        # Update Pet Display
        if (Existing := EquippedPetsList?) {EquippedPetsContainer.RemoveWidget(Existing)}

        if:
            Guy := Player.GetGuy[]
            var PlayerPetsAsSortedArray : []tuple(int, pet_data) = for (Id -> Data : Guy.Data.Pets). (Id, Data)
            set PlayerPetsAsSortedArray = utils_module.MergeSort(for (Id -> Data : Guy.Data.Pets). (Id, Data), IsPetMorePowerfulThan)
        then:
            var Widget:widget = EquippedView.Build(PlayerPetsAsSortedArray)
            EquippedPetsContainer.AddWidget of overlay_slot {Widget := Widget}
            set EquippedPetsList = option. Widget

        if:
            InfoHeader := _InfoHeader?
        then:
            InfoHeader.Refresh()

    #? ---

    OnMenuEnabled():void=
        LoadAllValidStoredPets()

        # Update Paginator Pages Text
        Paginator.SetPages(GetTotalPages())

        # Update Pet Display
        UpdateEquippedPetView()
        UpdateStoredPetView()

        # Play SFX
        GetGame().SFX.InventoryOpen.Play(Player)

        if (Guy := Player.GetGuy[]). Guy.UI.GoldCounter.DisableNewPetHint()

    GetTotalPages():int=
        if:
            Guy := Player.GetGuy[]
        then:
            Max(Ceil(Guy.Data.Pets.Length / Paginator.ItemsPerPage), 1) or 1
        else:
            1

    # Pet Boxes
    # GetPetBox<public>(Id:int):material=
    #     if (PetService := GetGame().Pets, Pet := PetService.GetDefinition[Id]):
    #         case(Pet.Rarity):
    #             pet_module.Service.rarity.Common => Assets.UI.Inventory.M_PetBox_Regular{} #bluish gray
    #             pet_module.Service.rarity.Rare => Assets.UI.Inventory.M_PetBox_Rare{} # green
    #             pet_module.Service.rarity.Epic => Assets.UI.Inventory.M_PetBox_Epic{} # purple
    #             pet_module.Service.rarity.Legendary => Assets.UI.Inventory.M_PetBox_Legendary{} # orange
    #             pet_module.Service.rarity.Mythical => Assets.UI.Inventory.M_PetBox_Mythical{} # red
    #             # not attainable through openings, upgrade tiers:
    #             pet_module.Service.rarity.Gold => Assets.UI.Inventory.M_PetBox_Gold{} #gold
    #             pet_module.Service.rarity.Rainbow => Assets.UI.Inventory.M_PetBox_Rainbow{} # rainbow
    #     else:
    #         Assets.UI.Inventory.M_PetBox_Regular{}

    GetRarityIcon<public>(Id:int)<transacts><decides>:texture=
        PetService := GetGame().Pets
        Pet := PetService.GetDefinition[Id]
        Pet.Rarity = pet_module.Service.rarity.Gold or Pet.Rarity = pet_module.Service.rarity.Rainbow

        case(Pet.Rarity):
            pet_module.Service.rarity.Gold => Assets.UI.Icons.Star_Gem_Yellow_Outline_64
            pet_module.Service.rarity.Rainbow => Assets.UI.Icons.T_Rarity_Rainbow
        
    OnPetEquipped(Id:int):void=UpdateEquippedPetView()
    OnPetUnequipped(Id:int):void=
        # Find existing instance of pet in stored view to avoid re-render
        for (Box : StoredView.TopBoxes, Pet := Box.Pet, Pet.Id = Id). return Box.RefreshInfo()
        for (Box : StoredView.BottomBoxes, Pet := Box.Pet, Pet.Id = Id). return Box.RefreshInfo()

        # Re-render the stored pet view.
        # Update Pet Display
        LoadAllValidStoredPets()

        if:
            Guy := Player.GetGuy[]
        then:
            if (Existing := StoredPetsList?) {StoredPetsContainer.RemoveWidget(Existing)}
            var Widget:widget = StoredView.Build(Self)                    
            StoredPetsContainer.AddWidget of overlay_slot {Widget := Widget}
            set StoredPetsList = option. Widget
        # spawn. DebouncedUnequip()
    
    UnequipEvent:event()=event(){}
    DebouncedUnequip()<suspends>:void=
        UnequipEvent.Signal()

        race:
            block:
                DebounceSleepTime := EquippedView.Children.Length > 0 and 0.0 or 0.0
                # Sleep(DebounceSleepTime)

                # Update Pet Display
                LoadAllValidStoredPets()

                if:
                    Guy := Player.GetGuy[]
                then:
                    if (Existing := StoredPetsList?) {StoredPetsContainer.RemoveWidget(Existing)}
                    var Widget:widget = StoredView.Build(Self)                    
                    StoredPetsContainer.AddWidget of overlay_slot {Widget := Widget}
                    set StoredPetsList = option. Widget

                Sleep(Inf)
            UnequipEvent.Await()

    OnNextPage():void=Paginator.Forward()
    OnPreviousPage():void=Paginator.Back()


    OnPetAwardedOrRemoved(Id:int):void=ForceRefresh()
    ForceRefresh():void=
        UpdateEquippedPetView()
        UpdateStoredPetView()

    OnEquipBestPets():void=
        if:
            Guy := Player.GetGuy[]
        then:
            Guy.Inventory.Pets.EquipBestPets()
            ForceRefresh()

    var _InfoHeader:?info = false
    var _InfoHeaderTotalPets:?info_total_pets = false

    #TODO: Make one bazillion benjamins 🤑👅
    Build<override>():void=
        # On Page Controls navigation buttons pressed
        Controls.NextPageActivated.Subscribe(OnNextPage)
        Controls.PreviousPageActivated.Subscribe(OnPreviousPage)

        Controls.EquipBestActivated.Subscribe(OnEquipBestPets)
        # Controls.UnequipAllActivated.Subscribe(OnUnequipAllPets)

        # On Paginator page number successfully updated (E.g. Page 1/3 -> Page 2/3)
        Paginator.PageUpdated.Subscribe(UpdateStoredPetView)
        Paginator.SetInfoTextBlock(Controls.InfoTextBlock)

        # Reload Pet View on Menu Opened
        OnEnable.Subscribe(OnMenuEnabled)

        # Update Equipped View on Pet Equipped
        if (Guy := Player.GetGuy[], Events := Guy.Events):
            Events.PetEquipped.Subscribe(OnPetEquipped)
            Events.PetUnequipped.Subscribe(OnPetUnequipped)

            Events.PetAwarded.Subscribe(OnPetAwardedOrRemoved)
            Events.PetRemoved.Subscribe(OnPetAwardedOrRemoved)
        Canvas := canvas{}

        InfoHeader := info{Player:=Player}
        InfoHeaderTotalPets := info_total_pets{Player:=Player}
        set _InfoHeader = option. InfoHeader
        set _InfoHeaderTotalPets = option. InfoHeaderTotalPets

        InnerContainerBody := stack_box:
            Orientation := orientation.Vertical
            Slots := array:                                
                # section title text
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := Margin(0, 0)
                    Widget := InfoHeader.Build()
                    
                # equipped pets view
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Top
                    Widget := EquippedPetsContainer

                # divider ----
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := Margin(0, 16, 0,8)
                    Widget := InfoHeaderTotalPets.Build()
                
                # stored pets view
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Top
                    Widget := StoredPetsContainer

                # controls
                stack_box_slot:
                    Distribution := option. 1.0
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Bottom
                    
                    Padding := margin{Bottom :=4.0}
                    Widget := Controls.Build()

        Anchors := anchors{Minimum := vector2{X := 0.2, Y := 0.17}, Maximum := vector2{X := 0.8, Y := 0.83}}
        Panel := panel{Parent := Self, Content := InnerContainerBody, Anchors := Anchors, Title := (Assets.UI.Icons.Pet_Brown_Outline_256, "PETS!")}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

# Utility function for MergeSort to order fish by descending rarity
IsPetMorePowerfulThan<public>(Left:tuple(int, pet_data), Right:tuple(int, pet_data))<decides><transacts>:tuple(int, pet_data)=
    LeftDef := GetGame().Pets.GetDefinition[Left(0)]
    RightDef := GetGame().Pets.GetDefinition[Right(0)]

    LeftLevel := if (LeftDef.IsMega?) then. LeftDef.Id + 1000000000 else. LeftDef.Level
    RightLevel:= if (RightDef.IsMega?) then. RightDef.Id+ 1000000000 else. RightDef.Level

    LeftLevel > RightLevel
    Left

MakePetInventory<public><constructor>(Player:player) := pet_inventory:
    Player := Player
        
    EquippedView := equipped_view{Player := Player}
    StoredView := stored_view{Player := Player}

    Controls := pet_controls{Player := Player}
    Paginator := pets_paginator{Player := Player}