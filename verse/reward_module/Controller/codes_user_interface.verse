using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }
using { EventModule }
using { utils_module }
using { guy_module.user_interface_module }

animation_type := enum{Error, Success}

codes_display<public> := class:
    Player<public>:player

    var TextBlock:text_block = text_block{}

    CancelAnimation:event()=event(){}
    Animate(Type:animation_type, Message:string)<suspends>:void=
        CancelAnimation.Signal()
        
        var Finished:logic = false

        Text := TextBlock.GetText()
        TextColor := TextBlock.GetTextColor()

        defer:
            # wasn't cancelled
            TextBlock.SetText(text.Make(Text))
            TextBlock.SetTextColor(TextColor)

        race:
            block:
                if (Type = animation_type.Error):
                    TextBlock.SetText(text.Make(Message))

                    From := MakeColorFromHex("D53234FF") # dark red
                    To := MakeColorFromHex("C8000AFF") # red

                    TextBlock.SetTextColor(From)
                    Sleep(0.2)
                    TextBlock.SetTextColor(To)
                    Sleep(0.2)
                    TextBlock.SetTextColor(From)
                    Sleep(0.2)
                    TextBlock.SetTextColor(To)
                    Sleep(0.2)
                    TextBlock.SetTextColor(From)
                    Sleep(0.2)
                    TextBlock.SetTextColor(To)
                    Sleep(0.5)
                                        
                else if (Type = animation_type.Success):
                    TextBlock.SetText(text.Make(Message))

                    From := MakeColorFromHex("00FF34FF") # dark green
                    To := MakeColorFromHex("7BFF58FF") # green

                    TextBlock.SetTextColor(From)
                    Sleep(0.2)
                    TextBlock.SetTextColor(To)
                    Sleep(0.2)
                    TextBlock.SetTextColor(From)
                    Sleep(0.2)
                    TextBlock.SetTextColor(To)
                    Sleep(0.2)
                    TextBlock.SetTextColor(From)
                    Sleep(0.2)
                    TextBlock.SetTextColor(To)
                    Sleep(0.5)

                set Finished = true

            CancelAnimation.Await()

    UpdateText(Value:[]int):void=
        CancelAnimation.Signal()

        if (Value.Length <= 0):
            TextBlock.SetText(text.Make("ENTER CODE HERE!"))
            TextBlock.SetTextColor(MakeColorFromHex("9FD5F5FF")) # grayed out
        else:
            Chars := for (ValueAsChar : Value). "{ValueAsChar}"
            TextBlock.SetText(text.Make(Join(Chars, " ")))
            TextBlock.SetTextColor(NamedColors.White)

    Build():overlay=
        set TextBlock = text_block{DefaultText := text.Make("ENTER CODE HERE!"), DefaultTextColor := MakeColorFromHex("9FD5F5FF"), DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}, DefaultShadowColor := NamedColors.Black, DefaultShadowOpacity := 1.0}
        
        overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Widget := Assets.UI.DarkUI.Containers.WB_Container_Blue_Opaque{} #Assets.UI.Inventory.WBP_Box_Primary{}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Padding := margin{Top:=24.0,Bottom:=24.0}
                    Widget := TextBlock

codes_input<public> := class:
    Player<public>:player
    KeyCode<public>:int = 1
    KeyPressed<public>:signal(int)

    OnButtonClicked(WM : widget_message):void=KeyPressed.Signal(KeyCode)        
        
    Build():overlay=
        Button := button_quiet{DefaultText := text.Make("{KeyCode}")}

        Button.OnClick().Subscribe(OnButtonClicked)

        overlay: 
            Slots := array:
                overlay_slot:
                    Widget := Assets.UI.Box.WBP_Box_Gold{}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Center
                    VerticalAlignment:=vertical_alignment.Center
                    Widget := color_block{DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=110.0, Y:=110.0}}
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := margin{Top:=16.0, Bottom:=16.0,Left:=16.0,Right:=16.0}
                    Widget := Button


codes<public> := class(user_interface):
    Interactive<override>:logic = true
    
    BlurBackground<override>:logic = true
    Sunburst<override>:logic = true
    
    Display<public>:codes_display
    KeyPressed:signal(int)=signal(int){}

    KeyLimit:int = 6

    var CurrentValue:[]int = array{}

    DoErrorAnimation(Message:string):void=
        spawn. Display.Animate(animation_type.Error, Message)
        GetGame().SFX.Error.Play(Player)
        
    OnKeyPressed(KeyCode:int):void=
        ValueLength := CurrentValue.Length

        #? Special keys
        # 10 = Delete
        if (KeyCode = 10):
            if (ValueLength > 0, NewValue := CurrentValue.RemoveElement[ValueLength-1], set CurrentValue = NewValue) {}
            Display.UpdateText(CurrentValue)
            return

        # 11 = Enter
        if (KeyCode = 11, Guy := Player.GetGuy[], InputAsStrArr := for (V : CurrentValue). "{V}", InputAsInt := ParseInt[Join(InputAsStrArr, "")]):
            Codes := GetGame().Rewards.GetCodes()

            for (Code : Codes):
                Success := Code.Verify(Guy, InputAsInt)
                if (Success?):
                    if (Code.IsExpired()?). return DoErrorAnimation("EXPIRED!")
                    if (Guy.Data.CodesRedeemed.Find[Code.Name]). return DoErrorAnimation("ALREADY REDEEMED!")

                    spawn. Display.Animate(animation_type.Success, "SUCCESS!")
                    GetGame().SFX.Success.Play(Player)

                    set Guy.Data.CodesRedeemed += array{Code.Name}
                    if (Guy.Data.Save[]) {}

                    spawn. Guy.UI.Notifications.PlayMessage("Redeemed {Code.Name}!")
                    
                    return Code.Award(Guy)

            return DoErrorAnimation("INVALID CODE!")

        # add key
        if (ValueLength < KeyLimit):
            set CurrentValue += array{KeyCode}
            Display.UpdateText(CurrentValue)
        else:
            # full
        
    OnDeleteActivated(WM:widget_message):void=OnKeyPressed(10)
    OnEnterActivated(WM:widget_message):void=OnKeyPressed(11)

    Build<override>():void=
        Canvas := canvas{}

        KeyPressed.Subscribe(OnKeyPressed)

        DeleteButton := button_quiet{}
        EnterButton := button_quiet{}

        DeleteButton.OnClick().Subscribe(OnDeleteActivated)
        EnterButton.OnClick().Subscribe(OnEnterActivated)
                
        InnerContainerBody := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                # stack_box_slot:
                #     HorizontalAlignment := horizontal_alignment.Center
                #     VerticalAlignment:=vertical_alignment.Center
                #     Padding := margin{Top := 6.0, Left := 20.0, Right := 20.0}
                #     Widget := Assets.UI.ItemUnlock.WBP_HeadingNow_Header{TextContent := text.Make("Free Pets, Boosts & More!")}

                # stack_box_slot:
                #     HorizontalAlignment := horizontal_alignment.Center
                #     VerticalAlignment:=vertical_alignment.Center
                #     Padding := margin{Top := 6.0, Left := 20.0, Right := 20.0}
                #     Widget := texture_block{DefaultImage := Assets.UI.Box.T_RewardCTA, DefaultDesiredSize := vector2{X:=440.0, Y:= 81.38}}
                # Current Input Display
                stack_box_slot:
                    Distribution := option. 1.0
                    Padding := margin{Left:=32.0,Right:=32.0,Top:=12.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Top
                    Widget := Display.Build()

                # Buttons
                    # 1, 2, 3
                    # 4, 5, 6
                    # 6, 7, 8 
                    # DEL, 0, ENTER
                stack_box_slot:
                    Padding := margin{Left:=32.0,Right:=32.0, Top:=12.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Widget := overlay:
                        Slots := array:
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := Assets.UI.Inventory.WBP_Box_Primary{}
                            overlay_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Padding := margin{Left:=16.0,Right:=16.0,Top:=16.0,Bottom:=16.0}
                                Widget := stack_box:
                                    Orientation := orientation.Vertical
                                    Slots := array:
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Widget := stack_box:
                                                Orientation := orientation.Horizontal
                                                Slots := array:
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := codes_input{Player := Player, KeyCode := 1, KeyPressed := KeyPressed}.Build()
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Padding := margin{Left := -24.0, Right := -24.0}
                                                        Widget := codes_input{Player := Player, KeyCode := 2, KeyPressed := KeyPressed}.Build()
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := codes_input{Player := Player, KeyCode := 3, KeyPressed := KeyPressed}.Build()

                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Padding := margin{Top := -16.0}
                                            Widget := stack_box:
                                                Orientation := orientation.Horizontal
                                                Slots := array:
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := codes_input{Player := Player, KeyCode := 4, KeyPressed := KeyPressed}.Build()
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Padding := margin{Left := -24.0, Right := -24.0}
                                                        Widget := codes_input{Player := Player, KeyCode := 5, KeyPressed := KeyPressed}.Build()
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := codes_input{Player := Player, KeyCode := 6, KeyPressed := KeyPressed}.Build()

                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Padding := margin{Top := -20.0}

                                            Widget := stack_box:
                                                Orientation := orientation.Horizontal
                                                Slots := array:
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := codes_input{Player := Player, KeyCode := 7, KeyPressed := KeyPressed}.Build()
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Padding := margin{Left := -24.0, Right := -24.0}
                                                        Widget := codes_input{Player := Player, KeyCode := 8, KeyPressed := KeyPressed}.Build()
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := codes_input{Player := Player, KeyCode := 9, KeyPressed := KeyPressed}.Build()
                                        
                                        stack_box_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Padding := margin{Top := -20.0, Left := 40.0, Right := 40.0}
                                            
                                            Widget := stack_box:
                                                Orientation := orientation.Horizontal
                                                Slots := array:
                                                    # DEL   
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := overlay: 
                                                            Slots := array:
                                                                overlay_slot:
                                                                    Widget := Assets.UI.Box.WBP_Box_Secondary{}
                                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                                    VerticalAlignment:=vertical_alignment.Fill
                                                                overlay_slot:
                                                                    HorizontalAlignment := horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget := color_block{DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=110.0, Y:=110.0}}
                                                                overlay_slot:
                                                                    Widget := texture_block{DefaultImage := Assets.UI.Icons.Trash_Flat_White_64, DefaultDesiredSize := vector2{X:=32.0, Y:=32.0}}
                                                                    HorizontalAlignment := horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                overlay_slot:
                                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                                    VerticalAlignment:=vertical_alignment.Fill
                                                                    Padding := margin{Top:=16.0, Bottom:=16.0,Left:=16.0,Right:=16.0}
                                                                    Widget := DeleteButton
                                                    # 0
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Padding := margin{Left := -24.0, Right := -24.0}
                                                        Widget := codes_input{Player := Player, KeyCode := 0, KeyPressed := KeyPressed}.Build()
                                                    # ENTER
                                                    stack_box_slot:
                                                        HorizontalAlignment := horizontal_alignment.Center
                                                        VerticalAlignment:=vertical_alignment.Center
                                                        Widget := overlay: 
                                                            Slots := array:
                                                                overlay_slot:
                                                                    Widget := Assets.UI.Box.WBP_Box_Green{}
                                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                                    VerticalAlignment:=vertical_alignment.Fill
                                                                overlay_slot:
                                                                    HorizontalAlignment := horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                    Widget := color_block{DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=110.0, Y:=110.0}}
                                                                overlay_slot:
                                                                    Widget := texture_block{DefaultImage := Assets.UI.Icons.Check_Mark_Flat_White_64, DefaultDesiredSize := vector2{X:=32.0, Y:=32.0}}
                                                                    HorizontalAlignment := horizontal_alignment.Center
                                                                    VerticalAlignment:=vertical_alignment.Center
                                                                overlay_slot:
                                                                    HorizontalAlignment := horizontal_alignment.Fill
                                                                    VerticalAlignment:=vertical_alignment.Fill
                                                                    Padding := margin{Top:=16.0, Bottom:=16.0,Left:=16.0,Right:=16.0}
                                                                    Widget := EnterButton
            
                # Reward Disclaimer
                stack_box_slot:
                    HorizontalAlignment := horizontal_alignment.Right
                    VerticalAlignment:=vertical_alignment.Bottom
                    Padding := margin{Top := 12.0}
                    Widget := text_block{DefaultText := text.Make(""), DefaultTextSize := 16.0}

        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
        Alignment := vector2{X:=0.5,Y:=0.5}
        Panel := panel{Parent := Self, Content := InnerContainerBody, Anchors := Anchors, Alignment := Alignment, SizeToContent := true, Title := (Assets.UI.Icons.gemBlue9, "CODES!")}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

MakeCodesUI<public><constructor>(Player:player) := codes:
    Player := Player
    Display := codes_display{Player := Player}