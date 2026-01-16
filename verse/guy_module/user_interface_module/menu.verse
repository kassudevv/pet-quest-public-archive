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

menu<public> := class(user_interface):
    Interactive<override>:logic = true
    
    BlurBackground<override>:logic = true
    
    ListenEvents()<suspends>:void=
        loop:
            OnEnable.Await()

            if (Guy := Player.GetGuy[], BestArea := GetGame().Areas.GetAreaFromId[Guy.Data.Areas[Guy.Data.Areas.Length-1]]):
                set BestAreaWidget.VTexture = BestArea.TeleportIcon
                set BestAreaWidget.VTitle = text.Make("Best Area")
                set BestAreaWidget.VDescription = text.Make("Area {BestArea.Id+1}")

    var BestAreaWidget :Assets.UI.DarkUI.VF_TeleportButton= Assets.UI.DarkUI.VF_TeleportButton{}

    ListenSpawnButton(Button:button_quiet)<suspends>:void=
        loop:
            Button.OnClick().Await()

            Target := luf_xform{Translation := luf_vec3{Left := 10526.877008, Up := 337.428471, Forward := -3528.46586}}

            if (Player.TeleportEntity[Target], Guy := Player.GetGuy[]):
                spawn. Guy.UI.Notifications.PlayMessage("Teleported to Spawn!")
                Disable()

            # if (Fort := Player.SafeFortCharacter[], Entity := Fort.GetEntity[]):
            # if (Fort := Player.SafeFortCharacter[], Fort.TeleportTo[Target.Translation, Target.Rotation]):
            #     Disable()

    ListenStatsButton(Button:button_quiet)<suspends>:void=
        loop:
            Button.OnClick().Await()

            if (Guy := Player.GetGuy[]):
                Disable()
                Guy.UI.Stats.Enable()

    ListenCodesButton(Button:button_quiet)<suspends>:void=
        loop:
            Button.OnClick().Await()

            if (Guy := Player.GetGuy[]):
                Disable()
                Guy.UI.Codes.Enable()
                
    ListenToggleHatching(Button:button_quiet)<suspends>:void=
        loop:
            Button.OnClick().Await()

            if (Guy := Player.GetGuy[]):
                IsEnabled := logic{not Guy.Data.AutoHatchEnabled?}
                set Guy.Data.AutoHatchEnabled = IsEnabled

                GetGame().Eggs.AutoHatchingToggle.SetState(Player, IsEnabled)
                if (IsEnabled?). spawn. Guy.UI.Notifications.PlayMessage("Enabled auto-hatching!")
                if (not IsEnabled?). spawn. Guy.UI.Notifications.PlayMessage("Disabled auto-hatching.", ?IsError := true)

                Disable()

    ListenToggleMusic(Button:button_quiet)<suspends>:void=
        loop:
            Button.OnClick().Await()

            if (Guy := Player.GetGuy[]):
                Guy.ToggleMusic()
                Disable()
    
    Build<override>():void=
        Canvas := canvas{}

        spawn. ListenEvents()

        StatsButton := button_quiet{DefaultText := text.Empty}
        CodesButton := button_quiet{DefaultText := text.Empty}
        MusicButton := button_quiet{DefaultText := text.Empty}
        AutoHatchButton := button_quiet{DefaultText := text.Empty}

        ButtonWidgetListener:[]tuple(button_quiet,Assets.UI.Rebirths.VF_MenuButton, type{_(:button_quiet)<suspends>:void}) = array:
            (button_quiet{DefaultText := text.Empty}, Assets.UI.Rebirths.VF_MenuButton{VText := text.Make("Redeem Codes"), VIcon := Assets.UI.Icons.Codes_Outline_256}, ListenCodesButton)
            (button_quiet{DefaultText := text.Empty}, Assets.UI.Rebirths.VF_MenuButton{VText := text.Make("View Stats"), VIcon := Assets.UI.Icons.trophy8}, ListenStatsButton)
            (button_quiet{DefaultText := text.Empty}, Assets.UI.Rebirths.VF_MenuButton{VText := text.Make("Toggle Music"), VIcon := Assets.UI.Icons.Sound_Outline_256}, ListenToggleMusic)
            (button_quiet{DefaultText := text.Empty}, Assets.UI.Rebirths.VF_MenuButton{VText := text.Make("Toggle Auto-Hatching"), VIcon := Assets.UI.Icons.Egg_Outline_256}, ListenToggleHatching)

        for (BWL:ButtonWidgetListener). spawn. BWL(2)(BWL(0))

        TopRow := stack_box {Orientation := orientation.Horizontal}
        BottomRow := stack_box {Orientation := orientation.Horizontal}

        if (BWL := ButtonWidgetListener[0], B := BWL(0), W:=BWL(1)):
            TopRow.AddWidget of stack_box_slot:
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
                                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=256.0,Y:=256.0}}
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget := B

                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment:=vertical_alignment.Center
                            Padding := margin{Top:=-2160.0}
                            Widget := W

        if (BWL := ButtonWidgetListener[1], B := BWL(0), W:=BWL(1)):
            TopRow.AddWidget of stack_box_slot:
                Padding := margin{Left := 24.0}
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
                                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=256.0,Y:=256.0}}
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget := B

                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment:=vertical_alignment.Center
                            Padding := margin{Top:=-2160.0}
                            Widget := W

        if (BWL := ButtonWidgetListener[2], B := BWL(0), W:=BWL(1)):
            BottomRow.AddWidget of stack_box_slot:
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
                                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=256.0,Y:=256.0}}
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget := B

                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment:=vertical_alignment.Center
                            Padding := margin{Top:=-2160.0}
                            Widget := W

        if (BWL := ButtonWidgetListener[3], B := BWL(0), W:=BWL(1)):
            BottomRow.AddWidget of stack_box_slot:
                Padding := margin{Left := 24.0}
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
                                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=256.0,Y:=256.0}}
                                    overlay_slot:
                                        HorizontalAlignment := horizontal_alignment.Fill
                                        VerticalAlignment:=vertical_alignment.Fill
                                        Widget := B

                        overlay_slot:
                            HorizontalAlignment := horizontal_alignment.Center
                            VerticalAlignment:=vertical_alignment.Center
                            Padding := margin{Top:=-2160.0}
                            Widget := W
                
        InnerContainerBody := overlay:
            Slots := array:
                overlay_slot:
                    Padding := Margin(48)
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget := TopRow
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Padding := margin{Top := 24.0}
                                Widget := BottomRow

        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
        Alignment := vector2{X:=0.5,Y:=0.5}
        Panel := panel{Parent := Self, Content := InnerContainerBody, Anchors := Anchors, Alignment := Alignment, SizeToContent := true, Title := (Assets.UI.Icons.Gear_2_Outline_256, "MENU!")}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

MakeMenuUI<public><constructor>(Player:player) := menu:
    Player := Player