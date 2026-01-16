using { /Fortnite.com/UI }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { EventModule }
using { guy_module.user_interface_module }

pet_controls<public> := class<unique>():
    Player<public>:player

    var Widget<public>:widget=overlay {}
    InfoTextBlock:text_block = text_block{DefaultText := text.Empty, DefaultTextColor := NamedColors.White}

    # Navigation signals
    PreviousPageActivated:signal(tuple()) = signal(tuple()){}
    NextPageActivated:signal(tuple()) = signal(tuple()){} 
    OnPreviousPage(WM : widget_message):void=PreviousPageActivated.Signal()
    OnNextPage(WM : widget_message):void=NextPageActivated.Signal()

    EquipBestActivated:signal(tuple()) = signal(tuple()){}
    UnequipAllActivated:signal(tuple()) = signal(tuple()){}
    OnEquipBest(WM : widget_message):void=EquipBestActivated.Signal()
    OnUnequipAll(WM : widget_message):void=UnequipAllActivated.Signal()

    Build<public>():widget=
        # Page Navigation Controls
        BackPageButton := button_quiet{DefaultText := text.Make("◀")}
        NextPageButton := button_quiet{DefaultText := text.Make("▶")}
        BackPageButton.OnClick().Subscribe(OnPreviousPage)
        NextPageButton.OnClick().Subscribe(OnNextPage)

        # Mass Equip and Unequip Controls
        EquipBestButton := button_quiet{DefaultText := text.Empty}
        # UnequipAllButton := button_quiet{DefaultText := text.Make("UNEQUIP ALL")}
        EquipBestButton.OnClick().Subscribe(OnEquipBest)
        # UnequipAllButton.OnClick().Subscribe(OnUnequipAll)

        OverlayWidget := overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment:=vertical_alignment.Center
                    Padding := margin{Right := 12.0}
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := EquipBestButton
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget := Assets.UI.DarkUI.WB_Button{VariationIdx := 1, TextContent := text.Make("Equip Best")}

                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Widget := overlay:
                        Slots := array:
                            # bg
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := Assets.UI.DarkUI.WB_Box_Filled{}

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

        set Widget = OverlayWidget

        Widget