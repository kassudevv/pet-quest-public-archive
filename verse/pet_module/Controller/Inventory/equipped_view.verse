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

equipped_pet_box<public> := class<unique>():
    Guy<public>:guy
    Maid:maid = maid{}

    # Pet definition data
    Pet<public>:pet_definition
    # Background box based on rarity
    RarityIdx<public>:int

    # Parent used for removing pet box
    Parent<public>:equipped_view
    
    # Player persistence data regarding pet
    var Data<public>:pet_data

    var Container:overlay = overlay{}
    var Content:stack_box = stack_box{Orientation := orientation.Vertical}

    var LevelInfoTextBlock:text_block = text_block{}
    var EquipButton:button_quiet = button_quiet{}
    var UnequipButton:button_quiet = button_quiet{DefaultText := text.Empty}

    var PetWidget:?Assets.UI.DarkUI.WB_Pet_Equipped=false

    RefreshInfo():void=
        if:
            NewData := Guy.Data.Pets[Pet.Id]
            set Data = NewData
        then:
            block {}

    OnUnequip(WM : widget_message):void=
        GetGame().SFX.InventoryShuffle.Play(Guy.Player)
        Guy.Inventory.Pets.UnequipPet(Pet.Id)
        spawn. Remove()

    GetVariationIdx():int=
        if (Pet.Rarity = rarity.Gold). return 1
        if (Pet.Rarity = rarity.Rainbow). return 2
        0

    Remove()<suspends>:void=
        if (Index := Parent.Children.Find[Self], Replaced := Parent.Children.RemoveElement[Index]). set Parent.Children = Replaced

        if (Parent.Children.Length > 0):
            UnequipButton.SetEnabled(false)

            Sleep(0.1)
            
            Parent.Widget.RemoveWidget(Container)
        else:
#            Print("last child, wait for refresh before disabling button")

            Sleep(0.2)

            UnequipButton.SetEnabled(false)

            # gives the inventory time to properly finish reloading
            Sleep(0.1)
            
            Parent.Widget.RemoveWidget(Container)

        Dispose()

    Dispose():void=Maid.Cleanup()

    Build():overlay=
        # Info text
        set LevelInfoTextBlock = text_block{DefaultText := text.Make("{Pet.Level}"), DefaultTextSize :=  48.0, DefaultTextColor := MakeColorFromHex("FFE400FF"), DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}, DefaultShadowColor := NamedColors.Black, DefaultShadowOpacity := 1.0}
        
        # Buttons
        set UnequipButton = button_quiet{DefaultText := text.Empty}
        Maid.AddCancelable(UnequipButton.OnClick().Subscribe(OnUnequip))

        RefreshInfo()

        MegaText := text.Make("???")

        WBPet := Assets.UI.DarkUI.WB_Pet_Equipped:
            RarityIdx := RarityIdx
            Icon := Pet.Icon
            Level := Pet.IsMega? and MegaText or text.Make("{Pet.Level.Format()}")
            VariationIdx := GetVariationIdx()
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
                                Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=110.0,Y:=110.0}}
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := UnequipButton

                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding := margin{Top:=-2160.0}
                    Widget := WBPet

        Container
equipped_view<public> := class<unique>():
    Player<public>:player

    var Widget<public>:stack_box=stack_box{Orientation:=orientation.Horizontal}
    var Children<public>:[]equipped_pet_box = array{}

    Build<public>(Pets : []tuple(int, pet_data)):stack_box=
        # properly clean up existing boxes
        for (Box : Children). Box.Dispose()
        set Children = array{}

        # build boxes
        if:
            Guy := Player.GetGuy[]
            PetService := GetGame().Pets   
        then:
            var Slots:[]stack_box_slot = array{}
            var IsFirst:logic = true

            set Widget = stack_box:
                Orientation := orientation.Horizontal
                Slots := array{}

            Widget.AddWidget of stack_box_slot:
                Widget := color_block{DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=0.0, Y:=120.0}}

            for:
                Index -> PetTuple : Pets
                Id := PetTuple(0)
                Data := PetTuple(1)
                
                Pet := PetService.GetDefinition[Id]
            do:
                for (I := 0..Data.Equipped-1):
                    Box := equipped_pet_box:
                        Parent := Self
                        RarityIdx := Guy.Eggs.GetRarityLabelWidgetSwitcherIndex(Pet.Rarity)

                        Guy := Guy
                        Pet := Pet
                        Data := Data

                    set Children += array{Box}

                    Widget.AddWidget of stack_box_slot:
                        Padding := margin{Left:=IsFirst? and 0.0 or 8.0}
                        Widget := Box.Build()

                    set IsFirst = false

        Widget