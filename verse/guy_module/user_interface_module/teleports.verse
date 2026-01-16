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

teleports<public> := class(user_interface):
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

    ListenBestAreaButton(Button:button_quiet)<suspends>:void=
        loop:
            Button.OnClick().Await()

            if (Guy := Player.GetGuy[], BestArea := GetGame().Areas.GetAreaFromId[Guy.Data.Areas[Guy.Data.Areas.Length-1]], not BestArea.HitDetector.IsNullPosition[]):
                Target := BestArea.HitDetector.GetTransform().ToLUF()

                if (Player.TeleportEntity[Target]):
                    spawn. Guy.UI.Notifications.PlayMessage("Teleported to Area #{BestArea.Id+1}!")
                    Disable()
    
    Build<override>():void=
        Canvas := canvas{}

        spawn. ListenEvents()

        SpawnButton := button_quiet{DefaultText := text.Empty}
        BestAreaButton := button_quiet{DefaultText := text.Empty}

        spawn. ListenSpawnButton(SpawnButton)
        spawn. ListenBestAreaButton(BestAreaButton)

        SpawnWidget := Assets.UI.DarkUI.VF_TeleportButton:
            VTitle := text.Make("Spawn")
            VDescription := text.Make("")
            VTexture := Assets.UI.DarkUI.T_Teleport_Spawn

        ButtonAndWidget:[]tuple(button_quiet, Assets.UI.DarkUI.VF_TeleportButton)=array{(SpawnButton,SpawnWidget),(BestAreaButton, BestAreaWidget)}
                
        InnerContainerBody := stack_box:
            Orientation := orientation.Vertical
            Slots := array:
                stack_box_slot:
                    Distribution := option. 1.0
                    Padding := margin{Left:=48.0,Right:=48.0,Top:=48.0, Bottom :=48.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := for (Idx->BW:ButtonAndWidget, B := BW(0), W:=BW(1)):
                            stack_box_slot:
                                Padding := Idx > 0 and margin{Top := 16.0} or margin{}
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
                                                        Widget := color_block{DefaultColor := NamedColors.Black, DefaultOpacity := 0.0, DefaultDesiredSize := vector2{X:=522.0,Y:=180.0}}
                                                    overlay_slot:
                                                        HorizontalAlignment := horizontal_alignment.Fill
                                                        VerticalAlignment:=vertical_alignment.Fill
                                                        Widget := B
                                        overlay_slot:
                                            HorizontalAlignment := horizontal_alignment.Center
                                            VerticalAlignment:=vertical_alignment.Center
                                            Padding := margin{Top:=-2160.0}
                                            Widget := W

        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
        Alignment := vector2{X:=0.5,Y:=0.5}
        Panel := panel{Parent := Self, Content := InnerContainerBody, Anchors := Anchors, Alignment := Alignment, SizeToContent := true, Title := (Assets.UI.Icons.Teleport_Outline_256, "TELEPORTS!")}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

MakeTeleportsUI<public><constructor>(Player:player) := teleports:
    Player := Player