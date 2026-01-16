using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }


pin_pad<public> := class(user_interface):
    Interactive<override>:logic = false

    Build<override>():void=
        Canvas := canvas{}

        Slot := canvas_slot:
            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
            Alignment := vector2{X := 0.5, Y := 0.5}
            SizeToContent := true

            Widget := overlay:
                Slots := array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget := Assets.UI.Box.WBP_Container{}
                    overlay_slot:
                        Widget := color_block{DefaultOpacity := 0.0}


        Canvas.AddWidget(Slot)

        set _Canvas = option {Canvas}