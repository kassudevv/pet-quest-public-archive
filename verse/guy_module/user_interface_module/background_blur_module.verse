using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

background_blur<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true

    Build<override>():void=
        if:
            Guy := Player.GetGuy[]
            UI := Guy.UI
            Canvas := UI.UniversalCanvas
        then:
            Widget := overlay:
                Slots := array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill

                        Widget := color_block:
                            DefaultColor := NamedColors.Black
                            DefaultOpacity := 0.7

            Slot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.0}, Maximum := vector2{X := 1.0, Y := 1.0}}
                Alignment := vector2{X := 0.0, Y := 0.0}
                Widget := Widget

            Canvas.AddWidget(Slot)
                
            set _Widget = option. Widget