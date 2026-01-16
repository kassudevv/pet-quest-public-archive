using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }

gold_counter<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true
    GoldCounterWidget :Assets.UI.Resources.WB_Gold= Assets.UI.Resources.WB_Gold{}
    PlayerInfoWidget :Assets.UI.Resources.WB_KeybindsAndResources= Assets.UI.Resources.WB_KeybindsAndResources{}

    Build<override>():void=
        if:
            Guy := Player.GetGuy[]
            UI := Guy.UI
            Canvas := UI.UniversalCanvas
        then:

            Slot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.02, Y := 0.5}, Maximum := vector2{X := 0.02, Y := 0.5}}
                Alignment := vector2{X := 0.0, Y := 0.5}
                Widget := PlayerInfoWidget

            Canvas.AddWidget(Slot)

            var State:int=0

            if (Guy.Data.QuestId < 8). set State = 1
            if (Guy.Data.QuestId = 8). set State = 2
            if (Guy.Data.QuestId = 22). set State = 3
            
            set PlayerInfoWidget.AreKeybindsLocked = State

            set _Widget = option. PlayerInfoWidget

    EnableNewPetHint<public>():void=set PlayerInfoWidget.VPetNotificationVisible = true
    DisableNewPetHint<public>():void=set PlayerInfoWidget.VPetNotificationVisible = false

    SetKeybindsVisibilityState<public>(State:int):void=
        set PlayerInfoWidget.AreKeybindsLocked = State

    var GoldAnimIncr:float = 0.0
    SetValue<public>(Value:float):void=
        set GoldAnimIncr += 1.0
        
        set PlayerInfoWidget.GoldAnimIncr = GoldAnimIncr
        set PlayerInfoWidget.Gold = text.Make("{Value.Format()}")