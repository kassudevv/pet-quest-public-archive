using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }

# User Interface Helper Class
user_interface<public> := class<abstract>():
  Player<public>:player

  # Is UI interactive?
  Interactive<protected>:logic = false

  # Don't create new canvas for non interactive stuff
  UseUniversalCanvas<protected>:logic=false
  var _Widget<public>:?widget = false
  
  # Background effects
  BlurBackground<protected>:logic=false
  Sunburst<protected>:logic=false
  SunburstSize<protected>:float=2500.0

  # Base Canvas
  var _Canvas<public>:?canvas = false

  # On Exit Event
  OnDisable<public>:event() = event(){}
  OnEnable<public>:event() = event(){}

  Build<public>():void=
    Err("User Interface | Must override Build method!")

  Enable<public>():void=
    if (Player.IsActive[], PlayerUI := GetPlayerUI[Player]):
      OnEnable.Signal()

      if (UseUniversalCanvas?,  Widget := _Widget?):
        Widget.SetVisibility(widget_visibility.Visible)
        return

      # Canvas exists.
      if (Canvas := _Canvas?):
        if (Interactive?):
          PlayerUI.AddWidget(Canvas, player_ui_slot{InputMode := ui_input_mode.All})
        else:
          PlayerUI.AddWidget(Canvas)
        Canvas.SetVisibility(widget_visibility.Visible)
      # Canvas does not exist, build it first.
      else:
        Build()
        Enable()

      if (BlurBackground?, Guy := Player.GetGuy[]). Guy.UI.BackgroundBlur.Enable()
      if (Sunburst?, Guy := Player.GetGuy[]):
        Guy.UI.BackgroundSunburst.Enable()
        if (Widget := Guy.UI.BackgroundSunburst.StoredMaterialBlock?):
          Widget.SetDesiredSize(vector2{X:=SunburstSize, Y:=SunburstSize})
      
  Disable<public>():void=
    if (UseUniversalCanvas?,  Widget := _Widget?):
        Widget.SetVisibility(widget_visibility.Hidden)

        return

    if (Canvas := _Canvas?, Player.IsActive[], PlayerUI := GetPlayerUI[Player]):
      # Interactive widgets have to be removed, otherwise just set visibility.
      if (Interactive?):
        PlayerUI.RemoveWidget(Canvas)
      else:
        Canvas.SetVisibility(widget_visibility.Hidden)

      if (BlurBackground?, Guy := Player.GetGuy[]). Guy.UI.BackgroundBlur.Disable()
      if (Sunburst?, Guy := Player.GetGuy[]). Guy.UI.BackgroundSunburst.Disable()
      
      OnDisable.Signal()
# Utility
texture_button<public> := struct:
  Widget:overlay
  Button:button_quiet

MakeTextureButton<public>(Texture:texture, Size:vector2 ):texture_button=
  Background := texture_block{DefaultImage := Texture, DefaultDesiredSize := Size}
  Button := button_quiet{}

  Overlay := overlay:
      Slots := array:
          overlay_slot:
              HorizontalAlignment := horizontal_alignment.Center
              VerticalAlignment:=vertical_alignment.Center
              Widget := Background
          overlay_slot:
              HorizontalAlignment := horizontal_alignment.Fill
              VerticalAlignment:=vertical_alignment.Fill
              Widget := Button

  return texture_button{Widget := Overlay, Button := Button}

text<public> := module:
  # Make Message
  Make<public><localizes>(Str:string):message="{Str}"

  # Message Presets
  Empty<public><localizes>:message=""
  Null<public><localizes>:message="0"
  Player<public><localizes>(Agent:player):message="{Agent}"
  Int<public><localizes>(Value:int):message="{Value}"
