using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { guy_module.user_interface_module }
using { utils_module }

pick_starter_pet<public> := class(user_interface):
    Interactive<override>:logic = true

    BlurBackground<override>:logic = true
    Sunburst<override>:logic = false

    PetChoices:[]string = array{"Dog", "Cat", "Mouse"}

    SelectEvent:event()=event(){}
    var SelectedPet:?pet_module.Service.pet_definition=false

    var IsButtonShown:logic=false

    ListenSelect(PetWidget:tuple(pet_module.Service.pet_definition, Assets.UI.Ftue.WB_PetPicker, button_quiet))<suspends>:void=
        Audio := GetGame().SFX.Bubble
        race:
            OnDisable.Await()
            loop:
                PetWidget(2).OnClick().Await()
                if (not SelectedPet? or SelectedPet?.Id <> PetWidget(0).Id):
                    set SelectedPet = option. PetWidget(0)
                    SelectEvent.Signal()
                    Audio.Play(Player)

                    # if (not IsButtonShown?):
                    #     set IsButtonShown = true
                    #     MainStackBox.AddWidget of stack_box_slot:
                    #         HorizontalAlignment := horizontal_alignment.Center
                    #         VerticalAlignment:=vertical_alignment.Center
                    #         Padding := margin{Bottom := 48.0, Top := 32.0}
                    #         Widget := overlay:
                    #             Slots := array:
                    #                 overlay_slot:
                    #                     HorizontalAlignment := horizontal_alignment.Fill
                    #                     VerticalAlignment:=vertical_alignment.Fill
                    #                     Widget := ClaimButton
                    #                 overlay_slot:
                    #                     HorizontalAlignment := horizontal_alignment.Center
                    #                     VerticalAlignment:=vertical_alignment.Center
                    #                     Widget := ClaimButtonWidget
            loop:
                SelectEvent.Await()
                set PetWidget(1).IsHintVisible = false
                if (Pet := SelectedPet?):
                    if (Pet.Id = PetWidget(0).Id):
                        set PetWidget(1).VariationIdx=0
                        set PetWidget(1).IsGrayedOut=0
                        set PetWidget(1).SelectAnimation += 1.0
                        set PetWidget(1).IsCheckBoxVisible=true
                    else:
                        set PetWidget(1).VariationIdx=1
                        set PetWidget(1).IsGrayedOut=1
                        set PetWidget(1).IsCheckBoxVisible=false
                else:
                    set PetWidget(1).IsGrayedOut=0
                    set PetWidget(1).VariationIdx=1
    
    ClaimButtonWidget :Assets.UI.DarkUI.WB_Button= Assets.UI.DarkUI.WB_Button{}
    ClaimedStarterPet:event()=event(){}
    ListenClaim(ClaimButton:button_loud)<suspends>:void=
        set ClaimButtonWidget.VariationIdx = 4
        race:
            OnDisable.Await()
            loop:
                ClaimButton.OnClick().Await()
                if (Pet := SelectedPet?):
                    GetGame().SFX.Success.Play(Player)
                    GetGame().SFX.Notification.Play(Player)
                    if (Guy := Player.GetGuy[]):
                        Guy.Inventory.Pets.AwardPet(Pet.Id)
                        Guy.Inventory.Pets.EquipPet(Pet.Id)
                    Disable()
            loop:
                SelectEvent.Await()
                set ClaimButtonWidget.VariationIdx = 0
                set HeaderWidget.TextContent = text.Make("Click \"Claim\"!")

    HeaderWidget:Assets.UI.Ftue.WB_Title=Assets.UI.Ftue.WB_Title{}

    var MainStackBox :stack_box= stack_box{Orientation := orientation.Vertical}

    # ClaimButton:button_quiet=button_quiet{DefaultText := text.}
    Build<override>():void=
        Canvas := canvas{}

        Pets := GetGame().Pets
        Choices := for (Name:PetChoices, Definition := Pets.GetDefinitionFromName[Name]). Definition

        PetWidgets := for (Pet:Choices). (Pet,Assets.UI.Ftue.WB_PetPicker{Icon := Pet.Icon, VariationIdx := 1}, button_quiet{})
        for (PetWidget : PetWidgets). spawn. ListenSelect(PetWidget)

        set ClaimButtonWidget.TextContent = text.Make("Claim!")
        set HeaderWidget.TextContent = text.Make("Choose a pet!")

        ClaimButton:button_loud = button_loud{DefaultText := text.Make("Claim")}
        spawn. ListenClaim(ClaimButton)

        ClaimButtonFixed := button:
            Slot := button_slot:
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment:=vertical_alignment.Center
                Widget := ClaimButton

        set MainStackBox = stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Widget := color_block{DefaultColor := NamedColors.White, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=800.0, Y:=0.0}}
                stack_box_slot:
                    Padding := margin{Top := 48.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Widget := HeaderWidget
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding := Margin(0, 32)
                    Widget := stack_box:
                        Orientation := orientation.Horizontal
                        Slots := for (Idx->PetWidget : PetWidgets):
                            stack_box_slot:
                                Padding := Idx = 0 and margin{} or margin{Left := 24.0}
                                Widget := overlay:
                                    Slots := array:
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Widget := overlay:
                                                Slots := array:
                                                    overlay_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=200.0,Y:=200.0}}
                                                    overlay_slot:
                                                        HorizontalAlignment := horizontal_alignment.Fill
                                                        VerticalAlignment:=vertical_alignment.Fill
                                                        Widget := PetWidget(2)
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Padding := margin{Top:=-2160.0}
                                            Widget := PetWidget(1)
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Bottom
                    Padding := margin{Bottom := 48.0, Top := 32.0}
                    Widget := ClaimButtonFixed

        InnerContainerBody := overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := Margin(0,64)
                    Widget := MainStackBox

        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
        Alignment := vector2{X:=0.5,Y:=0.5}
        Panel := panel{Parent := Self, Content := InnerContainerBody, Anchors := Anchors, Alignment := Alignment, SizeToContent := true, Title := (Assets.UI.Icons.Pet_Brown_Outline_256, "STARTER PET!"), ShowCloseButton := false}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

MakeStarterPetUI<public><constructor>(Player:player) := pick_starter_pet:
    Player := Player