using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }

panel<public> := class():
    Parent<public>:user_interface

    # Widgets
    Content<public>:widget
    Anchors<public>:anchors = anchors{Minimum := vector2{X := 0.1, Y := 0.1}, Maximum := vector2{X := 0.9, Y := 0.9}}
    Alignment<public>:vector2=vector2{X := 0.0, Y := 0.0}
    SizeToContent<public>:logic = false
    InfoBox<public>:widget = overlay{}
    Title<public>:tuple(texture,string)=(Assets.UI.Icons.gemBlue9, "Unknown")   
    ShowCloseButton<public>:logic=true

    OnExit(Message:widget_message):void=
        Parent.Disable()
    
    Build<public>():canvas_slot=
        # Exit Menu
        ExitButton := button_loud{DefaultText := text.Make("Close")}
        ExitButton.OnClick().Subscribe(OnExit)
        
        ExitButtonFixed := button:
            Slot := button_slot:
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment:=vertical_alignment.Center
                Widget := ExitButton

        InnerContainer := overlay:
            Slots := array:
                # Menu Container
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := Assets.UI.DarkUI.WB_UI_Container{TitleIcon := Title(0), TitleText := text.Make(Title(1))}
                overlay_slot:
                    Padding := margin{Left:=4.0, Right:=4.0,Top:=32.0,Bottom:=4.0}
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment := vertical_alignment.Fill
                    Widget := Content

        OverlayWidget := overlay:
                Slots := array:
                    # Page Content!
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Fill
                        VerticalAlignment := vertical_alignment.Fill
                        Widget := InnerContainer
                    # Header Info Box
                    overlay_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Top
                        Padding := margin{Top:=-32.0}
                        Widget := InfoBox

        BaseContainer := canvas_slot:
            Anchors := Anchors
            SizeToContent := SizeToContent
            Alignment := Alignment
            Widget := OverlayWidget
                    
        if (ShowCloseButton?):
            OverlayWidget.AddWidget of overlay_slot:
                HorizontalAlignment := horizontal_alignment.Fill
                VerticalAlignment:=vertical_alignment.Bottom
                Padding := margin{Bottom := -110.0}
                Widget := ExitButtonFixed

        BaseContainer