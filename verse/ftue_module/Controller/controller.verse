using { /Fortnite.com/Devices }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

controller<public> := class(guy_module.guy_extension):
    var ObjectiveDeviceClaimed:logic=false
    var ObjectiveDevice:objective_device=objective_device{}
    var HintEntity:entity=entity{}

    Init<override>():void=
        if:
            Guy := Player.GetGuy[]
            Data := Guy.Data
            SimEntity := GetGame().GetSimulationEntity[]
        then:
            set HintEntity = Assets.SG.HintEntity{}
            SetHintPresentable(false)
            SimEntity.AddEntities of array. HintEntity
            
            if (Data.QuestId = 0):
                Guy.UI.StarterPetDialog.Enable()
                Guy.UI.StarterPetDialog.OnDisable.Subscribe(StartListeningQuests)
            else if (Quest := GetGame().Ftue.Get[Guy.Data.QuestId]):
                StartListeningQuests()

    Dispose<override>():void=
        if (ObjectiveDeviceClaimed?):
            set GetGame().Ftue.ObjectiveDevices += array{ObjectiveDevice}
            set ObjectiveDeviceClaimed = false
            set ObjectiveDevice = objective_device{}

    StartListeningQuests<public>():void=
        if (not ObjectiveDeviceClaimed?):
            if:
                Dev := GetGame().Ftue.ObjectiveDevices[0]
                set ObjectiveDevice = Dev
                UpdatedArr := GetGame().Ftue.ObjectiveDevices.RemoveElement[0]
            then:
                set GetGame().Ftue.ObjectiveDevices = UpdatedArr
                set ObjectiveDeviceClaimed = true

        if:
            Guy := Player.GetGuy[]
            Data := Guy.Data
            
            Quest := GetGame().Ftue.Get[Guy.Data.QuestId]
        then:
            Guy.UI.Quests.Enable()
            Guy.UI.Quests.Refresh()

            spawn. ListenForProgress()

            spawn. HandleQuestStarted()
            QuestStartedEvent.Signal()

    # event handlers
    QuestStartedEvent:event()=event(){}
    QuestCompletedEvent:event()=event(){}

    HandleQuestStarted()<suspends>:void=
        Quests := GetGame().Ftue

        loop:
            QuestStartedEvent.Await()
            if:
                Guy := Player.GetGuy[]
                QuestInfo := Quests.Get[Guy.Data.QuestId]
            then:
                spawn. HandleQuestHint(Guy, QuestInfo.Objective)
    
    HandleQuestReward(Guy:guy_module.guy, Quest:Service.quest):void=
        if (Quest.Objective.RewardType <> ""):
            Print("Award reward: x{Quest.Objective.RewardAmount} {Quest.Objective.RewardType}")

        if (Analytics := GetGame().Analytics.QuestAnalytics[Quest.Id]). Analytics.Submit(Guy.Player)
        GetGame().Analytics.QuestCompleted.Award(Guy.Player)

        # Quest 8 = Gold Remote (Inventory) - Open your Inventory & Equip the Pet
        # Award all remotes once the player learns to use his inventory.
        if (Quest.Id = 8 or Quest.Id = 22):
            Guy.UI.GoldCounter.SetKeybindsVisibilityState(0)

    var IsHintVisible:logic=true
    SetHintPresentable(V:logic):void=
        if (not V = IsHintVisible):
            set IsHintVisible = V

            if (V?):
                HintEntity.SetPresentableToPlayers(option. array. Player)
            else:
                HintEntity.SetPresentableToPlayers(PresentableHiddenToAll)
                
    HandleQuestHint(Guy:guy_module.guy, Objective:ftue_module.Service.objective)<suspends>:void=
        defer: 
            ObjectiveDevice.DeactivateObjectivePulse(Player)
            SetHintPresentable(false)
        race:
            loop:
                if ((Objective.TargetType="earn_gold" or Objective.TargetType="destroy_breakable"), BestArea := GetGame().Areas.GetAreaFromId[Guy.Data.Areas[Guy.Data.Areas.Length-1]], Breakable := BestArea.GetClosestBreakable[Guy]):
                    HintPosition := Breakable.Prop.GetTransform().Translation+vector3{Z:=32.0}

                    if. ObjectiveDevice.TeleportTo[HintPosition, rotation{}]
                    ObjectiveDevice.ActivateObjectivePulse(Player)

                    SetHintPresentable(true)
                    HintEntity.SetGlobalTransform(luf_xform{Translation := HintPosition.ToLUF()})
                if (Objective.TargetType="hatch_egg"):
                    if (Position := GetGame().Eggs.GetClosestEggPurchasableLocation[Guy, ?EggId := Objective.TargetSpecifier]):
                        HintPosition := Position.Translation+vector3{Z:=100.0}
                        
                        if. ObjectiveDevice.TeleportTo[HintPosition, rotation{}]
                        ObjectiveDevice.ActivateObjectivePulse(Player)

                        SetHintPresentable(true)
                        HintEntity.SetGlobalTransform(luf_xform{Translation := HintPosition.ToLUF()})
                        Sleep(1.0)
                if (Objective.TargetType="unlock_area", Area := GetGame().Areas.GetAreaFromId[Objective.TargetSpecifier], Position := Area.AreaBorderEntityPosition.GetTransform()):
                    HintPosition := Position.Translation+vector3{Z:=-400.0}

                    if. ObjectiveDevice.TeleportTo[HintPosition, rotation{}]
                    ObjectiveDevice.ActivateObjectivePulse(Player)

                    SetHintPresentable(true)
                    HintEntity.SetGlobalTransform(luf_xform{Translation := HintPosition.ToLUF()})
                    Sleep(Inf) # sleep until unlocked
                if (Objective.TargetType="ftue_equip_pet"):
                    Sleep(2.0)
                    Guy.UI.GoldCounter.SetKeybindsVisibilityState(2) # display hint to open inventory
                    Guy.UI.PetInventory.OnEnable.Await() # inventory opened
                    Guy.UI.GoldCounter.SetKeybindsVisibilityState(0) # hide inventory hint
                    Sleep(0.1)
                    for (W : Guy.UI.PetInventory.StoredView.TopBoxes). W.EnableHint()
                    for (W : Guy.UI.PetInventory.StoredView.BottomBoxes). W.EnableHint()
                    Sleep(Inf) # sleep until completed
                if (Objective.TargetType="ftue_teleport_spawn"):
                    Guy.UI.GoldCounter.SetKeybindsVisibilityState(3) # display hint to open menu
                    Guy.UI.Teleports.OnEnable.Await()
                    Guy.UI.GoldCounter.SetKeybindsVisibilityState(0) # hide hint
                    Sleep(Inf) # sleep until completed
                Sleep(0.1)
            QuestCompletedEvent.Await()
            QuestStartedEvent.Await()

    ListenForProgress<public>()<suspends>:void=
        if:
            Guy := Player.GetGuy[]
            Events := Guy.Events
            Quests := GetGame().Ftue
        then:
            race:
                # Look for cop outs
                loop:
                    QuestStartedEvent.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="unlock_area", Guy.Data.Areas.Find[Quest.TargetSpecifier]). IncrementProgress(1)
                    
                loop:
                    EggHatchedId := Events.EggHatched.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="hatch_egg", (Quest.TargetSpecifier = -1 or Quest.TargetSpecifier = EggHatchedId)). IncrementProgress(1)
                loop:
                    Amount := Events.GoldAwarded.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="earn_gold"). IncrementProgress(Round[Amount] or 1)
                loop:
                    Id := Events.AreaUnlocked.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="unlock_area", Quest.TargetSpecifier = Id). IncrementProgress(1)
                loop:
                    Opened := Guy.Events.BreakableDestroyed.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="destroy_breakable"). IncrementProgress(1)
                loop:
                    Guy.UI.PetInventory.OnEnable.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="ftue_equip_pet"). IncrementProgress(1)
                loop:
                    Guy.UI.Teleports.OnEnable.Await()
                    if (Quest := Quests.Get[Guy.Data.QuestId].Objective, Quest.TargetType="ftue_teleport_spawn"). IncrementProgress(1)
                Guy.Events.Left.Await()
    
    # quest logic
    IncrementProgress<public>(Value:int):void=
        if:
            Guy := Player.GetGuy[]
            QuestInfo := GetGame().Ftue.Get[Guy.Data.QuestId]
            not IsCompleted?
        then:
            set Guy.Data.QuestProgress = Min(QuestInfo.Objective.TargetAmount, Guy.Data.QuestProgress+Value)
            if. Guy.Data.Save[]

            Step()

    Step<public>():void=
        if:
            Game := GetGame()
            Guy := Player.GetGuy[]
            QuestInfo := Game.Ftue.Get[Guy.Data.QuestId]
            not IsCompleted?
        then:
            Guy.UI.Quests.Refresh()
            if (Guy.Data.QuestProgress >= QuestInfo.Objective.TargetAmount):
                spawn {Complete()}

    var IsCompleted:logic=false
    Complete<public>()<suspends>:void=
        if:
            Game := GetGame()
            Guy := Player.GetGuy[]
            QuestInfo := Game.Ftue.Get[Guy.Data.QuestId]
        then:
            set IsCompleted = true

            Game.SFX.QuestCompleted.Play(Player)
            QuestCompletedEvent.Signal()

            Sleep(3.0)

            HandleQuestReward(Guy, QuestInfo)

            NextQuestId := Guy.Data.QuestId + 1
            set Guy.Data.QuestId = NextQuestId
            set Guy.Data.QuestProgress = 0
            set IsCompleted = false

            if (NextQuest := Game.Ftue.Get[NextQuestId]):
                Guy.UI.Quests.Refresh()
                Guy.UI.Quests.DoShakeAnim()
                Game.SFX.Notification.Play(Player)
                QuestStartedEvent.Signal()
            else:
                Guy.UI.Quests.Disable()

            if. Guy.Data.Save[]


MakeController<public><constructor>(Player:player) := controller:
    Player := Player