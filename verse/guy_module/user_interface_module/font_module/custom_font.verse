using { /Fortnite.com/UI }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { config_module }
using { utils_module }

font_block_cache := class:
    var Container:overlay
    var TextBox:?stack_box = false

font_block<public> := class():
    var Text<public>:string
    var Size<public>:float
    var Tracking<public>:float=0.0
    var Tint<public>:color=NamedColors.White
    var Font<public>:font_enum=font_enum.FredokaBold

    # Cache
    var Cache:font_block_cache = font_block_cache:
        Container := overlay{}
        TextBox := false

    SetText<public>(InText:string):void=
        set Text = InText
        Build()

    Build<public>():widget=
        CharToGlyph := GetGlyphSet(Font)

        BaseHeight := X:=CharToGlyph["N"].Dimensions.Y or 128.0 # glyph source height
        RemHeight := 16.0 * Size # fontSize
        Scale := RemHeight / BaseHeight

        TextBox := stack_box:
            Orientation := orientation.Horizontal
            Slots := for (Index->Char : Text):
                Glyph := CharToGlyph["{Char}"] or glyph {Texture := Assets.Fonts.T_Space, Dimensions := vector2{X:=CharToGlyph["N"].Dimensions.X * Scale or 0.0, Y:=0.0}}
                AdjustedSize := vector2 {X := Glyph.Dimensions.X * Scale, Y:= Glyph.Dimensions.Y * Scale}
                LetterSpacing := AdjustedSize.X * (Tracking / 100.0)

                stack_box_slot:
                    Padding := Index > 0 and margin{Left := LetterSpacing, Right := 0.0} or margin{}
                    Widget := texture_block{DefaultImage := Glyph.Texture, DefaultDesiredSize := AdjustedSize, DefaultTint := Tint}

        Container := Cache.Container

        if (ExistingText := Cache.TextBox?):
            Container.RemoveWidget(ExistingText)

        Container.AddWidget of overlay_slot:
            Widget := TextBox

        set Cache.TextBox = option {TextBox}

        Container


custom_font<public> := class(user_interface):
    Interactive<override>:logic = true

    OnExit(Message : widget_message):void=Disable()

    Build<override>():void=
        Canvas := canvas{}

        ExitButton := button_quiet{DefaultText := text.Make("EXIT!")}
        ExitButton.OnClick().Subscribe(OnExit)

        Config := config_module.GetConfig().UI

        ProgressText:text_block = text_block{
            DefaultText := text.Make("0/12 Rewards Claimed")
            DefaultTextColor := NamedColors.Black
            DefaultShadowColor := NamedColors.White
            DefaultShadowOffset := option{vector2{X:=1.0, Y:=1.0}}
            DefaultShadowOpacity := 1.0
        }

        TitleTextureBlock:texture_block = texture_block{DefaultImage := Assets.UI.Box.T_Title_Pets, DefaultDesiredSize := vector2{X:=512.0, Y:=128.0}}

        Slot := canvas_slot:
            Anchors := anchors{Minimum := vector2{X := 0.2, Y := 0.2}, Maximum := vector2{X := 0.8, Y := 0.8}}
            Alignment := vector2{X := 0.0, Y := 0.0}

            Widget := overlay:
                Slots:= array:
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment:=vertical_alignment.Fill
                        Widget := Assets.UI.Box.WBP_Container{}
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Left
                        VerticalAlignment:=vertical_alignment.Top
                        Padding := margin{Left := -32.0, Top := -48.0}
                        Widget := TitleTextureBlock
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Top
                        Padding := margin{Top := 128.0}
                        Widget := ProgressText
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Bottom
                        Widget := ExitButton
                    # overlay_slot:
                    #     HorizontalAlignment := horizontal_alignment.Fill
                    #     VerticalAlignment:=vertical_alignment.Fill
                    #     Widget := material_block{DefaultImage := Assets.Materials.NineSlice.M_RoundedPlane}
                    # overlay_slot:
                    #     HorizontalAlignment := horizontal_alignment.Fill
                    #     VerticalAlignment:=vertical_alignment.Fill
                    #     Widget := color_block{DefaultColor := NamedColors.White}
                    # overlay_slot:
                    #     HorizontalAlignment := horizontal_alignment.Fill
                    #     VerticalAlignment:=vertical_alignment.Fill
                    #     Widget := texture_block{DefaultImage := Assets.UI.Buttons.T_Pet_Tiling, DefaultHorizontalTiling := image_tiling.Repeat, DefaultVerticalTiling := image_tiling.Repeat, DefaultTint := MakeColorFromHex("F4F4F4FF")}
                    # overlay_slot:
                    #     HorizontalAlignment := horizontal_alignment.Left
                    #     VerticalAlignment:=vertical_alignment.Top
                    #     Padding := margin{Left:=Right:=Top:=Bottom:=40.0}
                    #     Widget := stack_box:
                    #         Orientation := orientation.Vertical
                    #         Slots := for (IDX := 0..9):
                    #             stack_box_slot:
                    #                 HorizontalAlignment := horizontal_alignment.Left
                    #                 Widget := font_block{Text := "Beep boop... Size := XL, Spacing := {IDX - 3}", Size := GetConfig().UI.Text.XL, Font := font_enum.FredokaBoldGradient, Tracking := IDX*1.0 - 3.0}.Build()
                            # Slots := array:
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "Beep boop... Font size before GTA 6?!", Size := 4.0, Spacing := 2.0, Tint:=NamedColors.Black}.Build()
                            #     # stack_box_slot:
                            #     #     HorizontalAlignment := horizontal_alignment.Left
                            #     #     Widget := custom_font_block{Text := "HELLO WORLD! SIZE: XS", Size := 2.0, Font := font_enum.FredokaBoldStroke}.Build()
                            #     # stack_box_slot:
                            #     #     HorizontalAlignment := horizontal_alignment.Left
                            #     #     Widget := custom_font_block{Text := "HELLO WORLD! SIZE: SM", Size := 3.0, Font := font_enum.FredokaBoldStroke}.Build()
                            #     # stack_box_slot:
                            #     #     HorizontalAlignment := horizontal_alignment.Left
                            #     #     Widget := custom_font_block{Text := "HELLO WORLD! SIZE: BASE", Size := 4.0, Font := font_enum.FredokaBoldStroke}.Build()
                            #     # stack_box_slot:
                            #     #     HorizontalAlignment := horizontal_alignment.Left
                            #     #     Widget := custom_font_block{Text := "HELLO WORLD! SIZE: LG", Size := 5.0, Font := font_enum.FredokaBoldStroke}.Build()
                            #     # stack_box_slot:
                            #     #     HorizontalAlignment := horizontal_alignment.Left
                            #     #     Widget := custom_font_block{Text := "HELLO WORLD! SIZE: XL", Size := 6.0, Font := font_enum.FredokaBoldStroke}.Build()
                            #     # stack_box_slot:
                            #     #     HorizontalAlignment := horizontal_alignment.Left
                            #     #     Widget := custom_font_block{Text := "HELLO WORLD! SIZE: GIANT", Size := 7.0, Font := font_enum.FredokaBoldStroke}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "563.3M GOLD", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#FECC0FFF")}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := -3.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := -2.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := -1.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := 0.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := 1.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := 2.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := 3.0}.Build()
                            #     stack_box_slot:
                            #         HorizontalAlignment := horizontal_alignment.Left
                            #         Widget := custom_font_block{Text := "147 REBIRTHS", Size := 7.0, Font := font_enum.FredokaBoldGradient, Tint := MakeColorFromHex("#E109FEFF"), Spacing := 4.0}.Build()    

        Canvas.AddWidget(Slot)

        set _Canvas = option {Canvas}
    
    Init<public>():void=Enable()