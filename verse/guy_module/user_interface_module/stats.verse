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
using { utils_module.time_module }

MakeIdentifierStr<public><localizes>(Player:player,Str:int):message="{Player} {Str}"

stats<public> := class(user_interface):
    Interactive<override>:logic = true
    
    BlurBackground<override>:logic = true
    
    StatsWidget:Assets.UI.Rebirths.WBP_Stats=Assets.UI.Rebirths.WBP_Stats{}

    Update():void=
        if (Guy := Player.GetGuy[]):
            PlaytimeInterval := MakeTimeInterval(Guy.Data.Playtime)

            set StatsWidget.VIdentifier = MakeIdentifierStr(Guy.Player, Guy.Data.Fingerprint)
            set StatsWidget.VPlaytime = text.Make("{PlaytimeInterval}")
            spawn. UpdatePlaytime()
            set StatsWidget.VEggsOpened = text.Make("{Guy.Data.EggsHatched.Format()}")
            
            var PetPower:float=Guy.Inventory.Pets.GetPowerStat()
            set StatsWidget.VPetPower = text.Make("{PetPower.Format()}")

            var TotalPetPower:float=Guy.Inventory.Pets.GetTotalPowerStat()
            set StatsWidget.VTotalPetPower = text.Make("{TotalPetPower.Format()}")

            set StatsWidget.VRebirths = text.Make("{Floor[Guy.Data.Rebirths] or 0}")

    UpdatePlaytime()<suspends>:void=
        if (Guy := Player.GetGuy[]):
            race:
                loop:
                    PlaytimeInterval := MakeTimeInterval(Guy.Data.Playtime)
                    set StatsWidget.VPlaytime = text.Make("{PlaytimeInterval}")
                    Sleep(1.0)
                OnDisable.Await()
                Guy.Events.Left.Await()
        
    Build<override>():void=
        Canvas := canvas{}

        OnEnable.Subscribe(Update)
        
        InnerContainer := overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := Margin(48)
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := StatsWidget


        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
        Alignment := vector2{X:=0.5,Y:=0.5}
        Panel := panel{Parent := Self, Content := InnerContainer, Anchors := Anchors, Alignment := Alignment, SizeToContent := true, Title := (Assets.UI.Icons.Star_Outline_256, "STATS!")}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

MakeStatsUI<public><constructor>(Player:player) := stats:
    Player := Player