using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { font_module }
using { utils_module }

background_sunburst<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true
    var StoredMaterialBlock:?material_block = false
    Build<override>():void=
        if:
            Guy := Player.GetGuy[]
            UI := Guy.UI
            Canvas := UI.UniversalCanvas
        then:
            SunburstMaterial := Assets.UI.Box.M_Background_Sunburst{}
            Widget := material_block{DefaultImage := SunburstMaterial, DefaultDesiredSize := vector2{X:=3500.0, Y:=3500.0}}
            Widget.SetImage(SunburstMaterial)
            set StoredMaterialBlock = option. Widget

            Slot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
                Alignment := vector2{X := 0.5, Y := 0.5}
                SizeToContent := true

                Widget := Widget

            Canvas.AddWidget(Slot)

            set _Widget = option. Widget