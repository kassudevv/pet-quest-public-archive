using { /UnrealEngine.com/Temporary/UI }
using { guy_module.user_interface_module }

font_size<public> := struct {
    XS:float = 1.0
    SM:float = 2.0
    Base:float = 3.0
    LG:float = 4.0
    XL:float = 5.0
}

font_tracking<public> := struct{
    Tighter:float = -3.0
    Tight:float = -2.0
    Normal:float = 0.0
    Wide:float = 2.0
    Wider:float = 3.0
    Widest:float = 4.0
}

font_enum<public> := enum{FredokaBold, FredokaBoldStroke, FredokaBoldGradient}

font_picker_fredoka<public> := struct {
    Fancy:font_enum = font_enum.FredokaBoldGradient
    Stroke:font_enum = font_enum.FredokaBoldStroke
    Regular:font_enum = font_enum.FredokaBold
}

font_picker<public> := struct {
    Fredoka:font_picker_fredoka = font_picker_fredoka{}
}

widgets<public> := class {
    Container<public>():widget=Assets.UI.DarkUI.WB_UI_Container{}
}

ui<public> := class():
    Text<public>:font_size = font_size{}
    Tracking<public>:font_tracking = font_tracking{}
    Font<public>:font_picker = font_picker{}

    Widgets<public>:widgets = widgets{}