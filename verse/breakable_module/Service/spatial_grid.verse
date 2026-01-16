using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Colors }
using { utils_module }

square := class:
    var Coins:[]collectable_item=array{}

spatial_grid<public> := class():
    # CONSTANTS
    CellSize:float = 100.0

    # VARIABLES
    var GridMap:[tuple(int,int)]square = map{}

    # METHODS
    RegisterCoin(Coin : collectable_item):tuple(int,int)=
        Translation := Coin.SpawnPosition

        FlatVec:tuple(int,int)= if (X := Floor[Translation.X / CellSize], Y := Floor[Translation.Y / CellSize]). (X, Y) else (0,0)
        if (not GridMap[FlatVec], set GridMap[FlatVec] = square {}) {}

        if. set GridMap[FlatVec].Coins += array{Coin}

        return FlatVec

    RemoveCoin(FlatVec:tuple(int,int),CoinToRemove:collectable_item):void=
        if (Square := GridMap[FlatVec]):
            set Square.Coins = for (Coin:Square.Coins, Coin<>CoinToRemove). Coin

    GetCoinsInRadiusCoarse(Position:vector3, Radius:float):[]square=
        Steps:int = Ceil[Radius / CellSize] or 0
        CenterX := Floor[Position.X / CellSize] or 0
        CenterY := Floor[Position.Y / CellSize] or 0

        var Result:[]square = array{}

        for (X := CenterX - Steps .. CenterX + Steps):
            for (Y := CenterY - Steps .. CenterY + Steps):
                Key:tuple(int,int) = (X,Y)
                if (Cell := GridMap[Key]):
                    set Result += array{Cell}

        return Result

    DebugDraw:debug_draw = debug_draw{Channel := global_debug_draw_channel}

    GetCoinsInRadius<public>(Position:vector3, Radius:float):[]collectable_item=
        var List:[]collectable_item = array{}
        CoarseList := GetCoinsInRadiusCoarse(Position, Radius)

        for (Record : CoarseList, Coin : Record.Coins):
            DistanceBetween := FastDistance(Position, Coin.SpawnPosition)
            if (DistanceBetween < Radius):
                set List += array{Coin}
            #     DebugDraw.DrawSphere(Center := Coin.SpawnPosition + vector3{Z:=150.0}, ?DrawDurationPolicy := debug_draw_duration_policy.FiniteDuration, ?Duration := 0.1, ?Color := NamedColors.Green)
            # else:
            #     DebugDraw.DrawSphere(Center := Coin.SpawnPosition + vector3{Z:=150.0}, ?DrawDurationPolicy := debug_draw_duration_policy.FiniteDuration, ?Duration := 0.1, ?Color := NamedColors.Orange)

        List