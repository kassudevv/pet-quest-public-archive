using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Simulation }

item_notification := class<unique>():
    Widget:Assets.UI.DarkUI.WB_ItemNotification=Assets.UI.DarkUI.WB_ItemNotification{}
    ItemName:string
    Icon:texture
    var Amount:float=0.0
    Parent:notifications
    NewItemText:string="New Item!"
    Build():Assets.UI.DarkUI.WB_ItemNotification=
        set Widget.IconTexture = Icon
        set Widget.NewItemText = text.Make(NewItemText)
        set Widget.CountText = if (Amount > 0.0) then text.Make("x{Amount.Format()}") else text.Empty
        
        Widget

    OnChanged:event()=event(){}
    IncrementAmount(By:float):void=
        set Amount += By
        set Widget.CountText = text.Make("x{Amount.Format()}")
        spawn. CloseAfterTimeout()

    PlayAnimation()<suspends>:void=
        set Widget.PlayShowAnim = 1.0
        spawn. CloseAfterTimeout()

    CloseAfterTimeout()<suspends>:void=
        OnChanged.Signal()

        var Closed:logic=false
        defer. if (not Closed?). set Widget.PlayCloseAnim = 0.0

        race:
            block:
                Sleep(3.0)
                set Widget.PlayCloseAnim = 1.0

                Sleep(0.8)

                set Closed = true
                Parent.ItemNotificationStackBox.RemoveWidget of Widget
                set Parent.ItemNotifications = for (Notification:Parent.ItemNotifications, Notification<>Self). Notification
            OnChanged.Await()

message_notification := class<unique>():
    Parent:notifications
    Widget:Assets.UI.DarkUI.WB_MessageNotification=Assets.UI.DarkUI.WB_MessageNotification{}
    Message:string
    Duration:float
    Variation:int=0

    Build():Assets.UI.DarkUI.WB_MessageNotification=
        set Widget.Text = text.Make(Message)
        set Widget.VariationIdx = Variation
        Widget

    OnChanged:event()=event(){}
    var Counter:int=1 
    IncrementCount():void=
        GetGame().SFX.Notification.Play(Parent.Player)
        set Counter += 1
        set Widget.Text = text.Make("{Message} (x{Counter})")
        spawn. CloseAfterTimeout()

    PlayAnimation()<suspends>:void=
        set Widget.PlayShowAnim = 1.0
        spawn. CloseAfterTimeout()

    CloseAfterTimeout()<suspends>:void=
        OnChanged.Signal()

        var Closed:logic=false
        defer. if (not Closed?). set Widget.PlayCloseAnim = 0.0

        race:
            block:
                Sleep(Duration)
                set Widget.PlayCloseAnim = 1.0

                Sleep(0.8)

                set Closed = true
                Parent.MessageNotificationStackBox.RemoveWidget of Widget
                set Parent.MessageNotifications = for (Notification:Parent.MessageNotifications, Notification<>Self). Notification
            OnChanged.Await()

notifications<public> := class(user_interface):
    UseUniversalCanvas<override>:logic = true

    var ItemNotifications:[]item_notification = array{}
    ItemNotificationStackBox:stack_box = stack_box{Orientation := orientation.Horizontal}

    var MessageNotifications:[]message_notification = array{}
    var MessageNotificationQueue:queue(message_notification) = queue(message_notification){}
    OnMessageQueued:event()=event(){}
    MessageNotificationStackBox:stack_box = stack_box{Orientation := orientation.Vertical}

    Build<override>():void=
        if:
            Guy := Player.GetGuy[]
            UI := Guy.UI
            Canvas := UI.UniversalCanvas
        then:
            Slot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.93}, Maximum := vector2{X := 0.5, Y := 0.93}}
                Alignment := vector2{X := 0.5, Y := 1.0}
                SizeToContent := true
                Widget := ItemNotificationStackBox
            Canvas.AddWidget(Slot)

            MessagesSlot := canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.75}, Maximum := vector2{X := 0.5, Y := 0.75}}
                Alignment := vector2{X := 0.5, Y := 1.0}
                SizeToContent := true
                Widget := MessageNotificationStackBox
            Canvas.AddWidget(MessagesSlot)

            spawn. MessagePlayer()
                
            set _Widget = option. ItemNotificationStackBox

    MessagePlayer()<suspends>:void=
        loop:
            Sleep(0.1)

            if (MessageNotifications.Length < 3, QueueResult := MessageNotificationQueue.Dequeue[], set MessageNotificationQueue = QueueResult(0), Noti := QueueResult(1)):
                set MessageNotifications += array. Noti
        
                Widget := Noti.Build()

                MessageNotificationStackBox.AddWidget of stack_box_slot:
                        HorizontalAlignment := horizontal_alignment.Center
                        VerticalAlignment:=vertical_alignment.Center
                        Padding := if (MessageNotifications.Length > 0) then margin{Bottom := 4.0} else margin{} 
                        Widget := Widget

                Noti.PlayAnimation()
                GetGame().SFX.Notification.Play(Player)

    PlayMessage<public>(Message:string, ?Duration:float=2.0, ?IsError:logic=false)<suspends>:void=
        if:
            Existing := (for (Noti : MessageNotifications, Noti.Message = Message). Noti)[0]
        then:
            Existing.IncrementCount()
        else:
            Noti := message_notification{Message:=Message,Duration:=Duration,Parent:=Self, Variation := if (IsError?) then 1 else 0}
            set MessageNotificationQueue = MessageNotificationQueue.Enqueue(Noti)

    PlayItem<public>(ItemName:string, Icon:texture, Amount:float, ?NewItemText:string="New Item!")<suspends>:void=
        if:
            Existing := (for (Noti : ItemNotifications, Noti.ItemName = ItemName). Noti)[0]
        then:
            Existing.IncrementAmount(Amount)
        else:
            Noti := item_notification{ItemName := ItemName, Icon := Icon, Parent := Self, Amount:=Amount, NewItemText := NewItemText}
            set ItemNotifications += array. Noti

            Widget := Noti.Build()

            ItemNotificationStackBox.AddWidget of stack_box_slot:
                HorizontalAlignment := horizontal_alignment.Center
                VerticalAlignment:=vertical_alignment.Center
                Padding := if (ItemNotifications.Length > 0) then margin{Left := 4.0} else margin{} 
                Widget := Widget

            Noti.PlayAnimation()
            GetGame().SFX.Bubble.Play(Player)

MakeItemNotifications<public><constructor>(Player:player) := notifications:
    Player := Player