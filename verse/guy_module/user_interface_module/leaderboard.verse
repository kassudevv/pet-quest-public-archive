using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

leaderboard<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true

    PlayerListSB:stack_box=stack_box{Orientation:=orientation.Vertical}

    Build<override>():void=
        if:
            Guy := Player.GetGuy[]
            UI := Guy.UI
            Canvas := UI.UniversalCanvas
        then:
            spawn. TrackPlayers()

            Widget := stack_box:
                Orientation := orientation.Vertical
                Slots := array:
                    stack_box_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Widget := Assets.UI.Rebirths.VF_LB_TopBar{}
                    stack_box_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget := overlay:
                            Slots := array:
                                overlay_slot:
                                    HorizontalAlignment := horizontal_alignment.Fill
                                    VerticalAlignment:=vertical_alignment.Fill
                                    Widget := Assets.UI.Rebirths.VF_LB_BottomBG{}
                                overlay_slot:
                                    HorizontalAlignment := horizontal_alignment.Fill
                                    VerticalAlignment:=vertical_alignment.Fill
                                    Padding := margin{Bottom := 4.0}
                                    Widget := PlayerListSB

            Slot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.98, Y := 0.03}, Maximum := vector2{X := 0.98, Y := 0.03}}
                Alignment := vector2{X := 1.0, Y := 0.0}
                Widget := Widget
                SizeToContent := true

            Canvas.AddWidget(Slot)

            set _Widget = option. Widget

    var Tracking:[player]logic=map{}
    TrackPlayers()<suspends>:void=
        for (Guy:GetGame().Guys.Guys):
            spawn. StartTrackingPlayer(Guy)
        
        loop:
            Guy := GetGame().Events.PlayerJoined.Await()
            spawn. StartTrackingPlayer(Guy)

    StartTrackingPlayer(Guy:guy_module.guy)<suspends>:void=
        if (OwnGuy := Player.GetGuy[], not Tracking[Guy.Player]?):
            if. set Tracking[Guy.Player] = true

            PlrWidget := Assets.UI.Rebirths.VF_LB_Player{VName := text.Make("Loading..."), VEggs := text.Make("?"), VPower := text.Make("?")}

            PlayerListSB.AddWidget of stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment:=vertical_alignment.Top
                Distribution := option{1.0}
                Widget := PlrWidget
            
            race:
                block:
                    Sleep(5.0)
                    set PlrWidget.VName = text.Player(Guy.Player)
                    set PlrWidget.VEggs = text.Make("{Guy.Data.EggsHatched.Format()}")
                    set PlrWidget.VPower = text.Make("{Guy.Inventory.Pets.GetPowerStat().Format()}")
                    Sleep(Inf)
                loop:
                    Guy.Events.PetPawnAdded.Await()
                    set PlrWidget.VPower = text.Make("{Guy.Inventory.Pets.GetPowerStat().Format()}")
                loop:
                    Guy.Events.PetPawnRemoved.Await()
                    set PlrWidget.VPower = text.Make("{Guy.Inventory.Pets.GetPowerStat().Format()}")
                loop:
                    Guy.Events.EggHatched.Await()
                    set PlrWidget.VEggs = text.Make("{Guy.Data.EggsHatched.Format()}")
                block:
                    Guy.Events.Left.Await()
                    PlayerListSB.RemoveWidget of PlrWidget
                    if. set Tracking[Guy.Player] = false

                OwnGuy.Events.Left.Await()
            