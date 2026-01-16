using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { guy_module.user_interface_module }
using { utils_module }

quests_ui<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true
    var QuestWidget :Assets.UI.Ftue.WB_Quest= Assets.UI.Ftue.WB_Quest{}

    var ShowAnimIncr:float=0.0
    var ShakeAnimIncr:float=0.0

    DoShowAnim<public>():void=
        set ShowAnimIncr += 1.0
        set QuestWidget.ShowAnimIncr = ShowAnimIncr

    DoShakeAnim<public>():void=
        set ShakeAnimIncr += 1.0
        set QuestWidget.ShakeAnimationIncr = ShakeAnimIncr
    
    Build<override>():void=
        if:
            Guy := Player.GetGuy[]
            UI := Guy.UI
            Canvas := UI.UniversalCanvas
        then:
            OnEnable.Subscribe(DoShowAnim)

            set QuestWidget = Assets.UI.Ftue.WB_Quest:
                TitleText := text.Make("More Pets")
                DescriptionText := text.Make("Hatch 1 Basic Egg")
                Progress := 0.5
                ProgressText := text.Make("5/10")
                HasReward := false

            Slot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.03}, Maximum := vector2{X := 0.5, Y := 0.03}}
                Alignment := vector2{X := 0.5, Y := 0.0}
                SizeToContent := true
                Widget := QuestWidget

            Canvas.AddWidget(Slot)
                
            set _Widget = option. QuestWidget

    Refresh<public>():void=
        if:
            Guy := Player.GetGuy[]

            Ftue := GetGame().Ftue
            Quest := Ftue.Get[Guy.Data.QuestId]
            Objective := Quest.Objective
        then:
            set QuestWidget.TitleText = text.Make(Objective.Title)
            set QuestWidget.DescriptionText = text.Make(Objective.Description)
            set QuestWidget.IconTexture = Ftue.GetIcon(Objective.TargetType, Objective.TargetSpecifier)
            
            Progress:float= (Guy.Data.QuestProgress*1.0) / (Objective.TargetAmount*1.0)
            set QuestWidget.Progress = Progress
            ProgressText := text.Make("{Guy.Data.QuestProgress}/{Objective.TargetAmount}")
            set QuestWidget.ProgressText = Progress < 1.0 and ProgressText or text.Make("Done!")

MakeQuestsUI<public><constructor>(Player:player) := quests_ui:
    Player := Player