using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { font_module }
using { utils_module }

currency_display<public> := class():
    Texture<public>:texture
    FontBlock<public>:text_block

    SetValue<public>(Amount:float, ?Instant:logic = false):void=
        if (Instant?):
            set CurrentValue = Amount * 1.0
            FontBlock.SetText(text.Make("{Amount.Format()}"))
        else:
            #? LERP!
            spawn {AnimateTo(Amount*1.0)}

    #? Animation
    AnimationLength:float = 2.0
    AnimateEvent:event() = event(){}

    var CurrentValue:float = 0.0

    AnimateTo(TargetValue:float)<suspends>:void=
        AnimateEvent.Signal()

        StartValue := CurrentValue
        StartTime := GetSimulationElapsedTime()

        race:
            AnimateEvent.Await()
            loop:
                Progress := (GetSimulationElapsedTime() - StartTime) / AnimationLength
                set CurrentValue = Lerp(StartValue, TargetValue, EaseOutCubic(Progress))
                FontBlock.SetText(text.Make("{CurrentValue.Format()}"))

                if (Progress >= 1.0). break
                Sleep(0.0)

currency<public> := class(user_interface):
    var Displays<public>:[resource_type]currency_display = map{}

    PopulateValues():void=
        if:
            Data := Player.GetGuy[].Data
            Resources := Player.GetGuy[].Resources

            Gems := Resources.Get[resource_type.Gems]
            Gold := Resources.Get[resource_type.Gold]
            Rebirths := Resources.Get[resource_type.Rebirths]

            GoldDisplay := Displays[resource_type.Gold]
            GemsDisplay := Displays[resource_type.Gems]
            RebirthsDisplay := Displays[resource_type.Rebirths]

        then:
            GoldDisplay.SetValue(Gold, ?Instant := true)
            GemsDisplay.SetValue(Gems, ?Instant := true)
            RebirthsDisplay.SetValue(Rebirths, ?Instant := true)


    Build<override>():void=
        Config := config_module.GetConfig().UI

        Canvas := canvas{}

        set Displays = map:
            resource_type.Rebirths => currency_display{Texture := Assets.UI.Icons.Currency_Rebirth, FontBlock := text_block{DefaultText := text.Empty}}
            resource_type.Gold => currency_display{Texture := Assets.UI.Icons.Currency_Gold, FontBlock := text_block{DefaultText := text.Empty}}
            resource_type.Gems => currency_display{Texture := Assets.UI.Icons.Currency_Gems, FontBlock := text_block{DefaultText := text.Empty}}

        Slot := canvas_slot:
            Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
            Alignment := vector2{X := 0.5, Y := 0.0}
            SizeToContent := true

            Widget := overlay:
                Slots := array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Top
                        Padding := margin{Top := 32.0}
                        Widget := stack_box:
                            Orientation := orientation.Horizontal
                            Slots:= for (Index->Currency : Displays):
                                stack_box_slot:
                                    HorizontalAlignment := horizontal_alignment.Center
                                    VerticalAlignment:=vertical_alignment.Top
                                    Padding := Index = 1 and margin{Left:= 32.0, Right:=32.0} or margin{}
                                    Widget := overlay:
                                        Slots := array:
                                            overlay_slot:
                                                Widget := texture_block{DefaultImage := Currency.Texture, DefaultDesiredSize := Vec(512.0*0.75, 128.0*0.75)}
                                            overlay_slot:
                                                HorizontalAlignment := horizontal_alignment.Left
                                                VerticalAlignment:=vertical_alignment.Center
                                                Padding := margin{Left := 128.0}

                                                Widget := Currency.FontBlock


        Canvas.AddWidget(Slot)

        set _Canvas = option { Canvas }

        PopulateValues()