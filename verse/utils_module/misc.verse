using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Concurrency }
using { /Verse.org/Simulation }
using { EventModule }

# Distance between 2 transforms
Distance<public>(Start:transform, End:transform):float=
  FastDistance(Start.Translation, End.Translation)

# Debug Prints
InfoLevelToColor:[int]color = map{
  2 => NamedColors.Cyan
  1 => NamedColors.Gold
  0 => NamedColors.Orange
}

Info<public>(Message:[]char, ?Duration:float = 30.0, ?Level:int = 0):void=
  Color := InfoLevelToColor[Level] and InfoLevelToColor[Level] or NamedColors.Gold
  Print("--{Message}--", ?Duration := Duration, ?Color := Color)

# Debug Time
(PreviousTime:float).GetDeltaTime<public>():float=
  CurrentTime:=GetSimulationElapsedTime()
  DeltaTime:=CurrentTime - PreviousTime

(PreviousTime:float).PrintDeltaTime<public>(Note:string):void=
  CurrentTime:=GetSimulationElapsedTime()
  DeltaTime:=CurrentTime - PreviousTime
  Print("{Note}:{DeltaTime}")

# Maid Helper class from Roblox
maid<public> := class:
    var CustomCancelables:[]custom_cancelable = array{}
    var Cancelables:[]cancelable = array{}

    Add<public>(Cancelable:custom_cancelable):void=
        set CustomCancelables += array{Cancelable}
    AddCancelable<public>(Cancelable:cancelable):void=
        set Cancelables += array{Cancelable}

    Cleanup<public>():void=
        for (Cancelable:Cancelables). Cancelable.Cancel()
        for (Cancelable:CustomCancelables). Cancelable.Cancel()


# Mainly used for checking if a device is valid
(Object : creative_object).IsNullPosition<public>()<decides><transacts>:void=
  Transform := Object.GetTransform()

  Transform.Translation.X = 0
  Transform.Translation.Y = 0
  Transform.Translation.Z = 0

# Delay removing something like Maid:AddDebris
(Object : creative_prop).DelayedDispose<public>(Time:float)<suspends>:void=
  Sleep(Time)

  if (Object.IsValid[]):
    Object.Dispose()

Vec<public>(X:float, Y:float)<computes>:vector2=vector2{X:=X, Y:=Y}
Vec<public>(X:float, Y:float, Z:float)<computes>:vector3=vector3{X:=X, Y:=Y, Z:=Z}

EaseOutCubic<public>(T:float):float=
  NewT := Clamp(T, 0.0, 1.0)
  1.0 - Pow(1.0 - NewT, 3.0)

# Event sub
(E : event()).Subscribe<public>(Callback:type{func():void}):void=
  spawn {E.LoopCallbackOnEvent(Callback)}

(E : event()).LoopCallbackOnEvent<public>(Callback:type{func():void})<suspends>:void=
  loop:
      E.Await()
      Callback()

# Convert from UMG color to In-Game
LinearColorToSRGB<public>(Color : color) : color =
  SRGB := MakeSRGBFromColor(Color)
  return color{
      R := Pow(SRGB(0),2.2),
      G := Pow(SRGB(1),2.2),
      B := Pow(SRGB(2),2.2)
  }

# Await for
(Awaitable:awaitable(payload)).AwaitFor<public>(TargetPayload:payload where payload:subtype(comparable))<suspends>:void =
{
    loop:
        Payload := Awaitable.Await()
        if(Payload = TargetPayload){break}
}

# string to int
ParseInt<public>(String:string)<decides><transacts>:int=
    Characters:string = "0123456789"
    var Result:int = 0
    Sign:int = String[0] = "-" and -1 or 1
    for (Index->Char : String, Index > 0 or Sign = 1, Found := Characters.Find[Char]):
        set Result = Result * 10 + Found
    Result * Sign

# cast int to float and vice versa
Float(Number : int)<reads><allocates>:float=
  return Number * 1.0
 
operator'+'(I:int, F:float):float=
    return I * 1.0 + F
 
operator'+'(F:float, I:int):float=
    return F + I * 1.0
 
operator'-'(I:int, F:float):float=
    return I * 1.0 - F
 
operator'-'(F:float, I:int):float=
    return F - I * 1.0
 
operator'/'(I:int, F:float):float=
    return I * 1.0 / F
 
operator'/'(F:float, I:int):float=
    return F / (I * 1.0)

# Create verse ui paddings shorthand
Margin<public>(X:int):margin=Margin(X*1.0,X*1.0,X*1.0,X*1.0)
Margin<public>(X:int, Y:int):margin=Margin(X*1.0,Y*1.0,X*1.0,Y*1.0)
Margin<public>(X:int, Y:int, Z:int, W:int):margin=Margin(X*1.0,Y*1.0,Z*1.0,W*1.0)

Margin<public>(Left:float, Top:float, Right:float, Bottom:float):margin=margin{Left:=Left, Top:=Top, Right:=Right, Bottom:=Bottom}

# Vector shorthand
Vec2<public>(X:int,Y:int):vector2=Vec2(X*1.0,Y*1.0)
Vec2<public>(X:float,Y:float):vector2=vector2{X:=X,Y:=Y}

IsExpired(Now:float, CreatedAt:float, Days:float):void=
  Print("CHECKING!")

  Interval := time.MakeTimeInterval(1, 0, 0, 0.0)
  Result := logic{(CreatedAt + Interval) > Now}

time<public> := module:
  DaysInMonth:[]int = array{31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
  # Succeeds if the year is a leap year.
  IsLeapYear<public>(Year:int)<decides><transacts>:void=
    Mod[Year, 4] = 0 and (Mod[Year, 100] <> 0 or Mod[Year, 400] = 0)
  
  DateToUnixTimestamp<public>(Year:int, Month:int, Day:int, Hour:int, Minute:int, Second:int)<transacts>:float =
    # --- Input Validation ---
    if (Month < 1 or Month > 12 or Day < 1 or Day > 31 or Hour < 0 or Hour > 23 or Minute < 0 or Minute > 59 or Second < 0 or Second > 59):
        Print("Invalid date or time input.")
        return 0.0

    # --- Calculate Total Days from Epoch ---
    var TotalDays:int = 0

    # 1. Add days for all the full years since 1970
    for (Y := 1970..Year-1):
        set TotalDays += if (IsLeapYear[Y]) then 366 else 365

    # 2. Add days for all the full months in the current year
    for (M := 1..Month-1, Amount := DaysInMonth[M - 1]):
        set TotalDays += Amount
        # Add an extra day for February in a leap year
        if (M = 2 and IsLeapYear[Year]):
            set TotalDays += 1

    # 3. Add the days in the current month
    set TotalDays += (Day - 1)

    # --- Calculate Total Seconds ---
    TotalSecondsInDays := TotalDays * 86400 # (24 hours * 60 minutes * 60 seconds)
    SecondsInCurrentDay := Hour * 3600 + Minute * 60 + Second

    return TotalSecondsInDays * 1.0 + SecondsInCurrentDay * 1.0

  MakeTimeInterval<public>(Days:int, Hours:int, Minutes:int, Seconds:float)<transacts>:float =
      Days * 3600.0 * 24.0 +
      Hours * 3600.0 +
      Minutes * 60.0 +
      Seconds

  GetMinutes<public>(TimeInterval:float)<transacts>:float =
    TimeInterval / (SecondsInAMinute)

  GetHours<public>(TimeInterval:float)<transacts>:float =
    TimeInterval / (SecondsInAnHour)

  GetDays(TimeInterval:float)<transacts>:float =
    TimeInterval / (SecondsInAnHour * 24.0)

  SecondsInADay:float = 86400.0
  SecondsInAnHour:float = 3600.0
  SecondsInAMinute:float= 60.0