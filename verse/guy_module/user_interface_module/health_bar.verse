using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { utils_module }

health_bar<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true

    HealthBarMaterial:Assets.UI.HealthBar.M_HealthBar_UI = Assets.UI.HealthBar.M_HealthBar_UI{}
    MaterialBlock:material_block = material_block{DefaultImage := Assets.UI.HealthBar.M_HealthBar_UI{}, DefaultDesiredSize := vector2{X:=512.0, Y:=64.0}}

    ProgressText:text_block = text_block{DefaultText := text.Empty, DefaultTextColor := NamedColors.White, DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}, DefaultShadowColor := NamedColors.Black, DefaultShadowOpacity := 1.0}

    var Progress:float=1.0

    Build<override>():void=
        Canvas := canvas{}

        MaterialBlock.SetImage(HealthBarMaterial)
        SetProgress(100.0, 100.0, ?Instant := true)

        Slot := canvas_slot:
            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.1}, Maximum := vector2{X := 0.5, Y := 0.1}}
            Alignment := vector2{X := 0.5, Y := 0.5}
            SizeToContent:=true

            Widget := stack_box:
                Orientation := orientation.Vertical
                Slots := array:
                    stack_box_slot:
                        Widget := MaterialBlock                        
                    stack_box_slot:
                        HorizontalAlignment := horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Center
                        Widget := stack_box:
                            Orientation := orientation.Horizontal
                            Slots := array:
                                stack_box_slot:
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment:=vertical_alignment.Center
                                    Widget := texture_block{DefaultImage := Assets.UI.Icons.Heart_Outline_256, DefaultDesiredSize := Vec2(32,32)}
                                stack_box_slot:
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment:=vertical_alignment.Center
                                    Padding := Margin(8,0,0,0)
                                    Widget := ProgressText

        Canvas.AddWidget(Slot)

        set _Canvas = option. Canvas

    ProgressChanged:event()=event(){}
    SetProgress<public>(Health:float, MaxHealth:float, ?Instant:logic=false):void=
        ProgressText.SetText(text.Make("{Health.Format()} / {MaxHealth.Format()}"))

        # Animate or set progress bar material value
        if (Instant?):
            set Progress = Health / MaxHealth
            set HealthBarMaterial.Progress = Progress
        else:
            spawn. _AnimateProgress(Health / MaxHealth)

    _AnimateProgress(TargetValue:float)<suspends>:void=
        ProgressChanged.Signal()

        StartValue := Progress
        StartTime := GetSimulationElapsedTime()
        AnimationLength := 0.333

        race:
            loop:
                if (Progress <= TargetValue). return

                Position := (GetSimulationElapsedTime() - StartTime) / AnimationLength
                set Progress = Lerp(StartValue, TargetValue, EaseOutCubic(Position))
                set HealthBarMaterial.Progress = Progress
                
                Sleep(0.0)
            ProgressChanged.Await()