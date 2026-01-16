using { /Fortnite.com/Devices }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { main_module }
using { utils_module }

resource_type<public> := enum{Rebirths, Gold, Gems}

resources<public> := class(guy_extension):
    var GoldGainMessages:[]gold_gain_message = array{}

    Init<override>():void=
        Info("Initializing Resource Controller")
        set GoldGainMessages = for (Device:GetGame().Messages.GoldGainDevices). gold_gain_message{Device := Device, Player:=Player}

    # Has enough of resource
    Has<public>(Type:resource_type, Amount:float)<transacts><decides>:void=
        Current := Get[Type]
        Current >= Amount

    # Award resource
    Award<public>(Type:resource_type, Amount:float):void=
        if (Current := Get[Type]):
            # info
            if (Type = resource_type.Gold, GoldGainPlayer := GetRandomGoldGainPlayer[]):
                GoldGainPlayer.Play(Amount)
                if (Guy := Player.GetGuy[]):
                    set Guy.Data.GoldEarned += Amount
                    Guy.Events.GoldAwarded.Signal(Amount)
                    spawn. Guy.UI.Notifications.PlayItem("Gold", Assets.UI.Icons.Coin_Outline_64, Amount)

            Set(Type, Current + Amount)
        else:
            Print("⚠️ WARNING: resources.Award - Failed to get resource of type.")

    # Remove resource, has to have enough
    Remove<public>(Type:resource_type, Amount:float):logic=
        if:
            Has[Type, Amount]
            Current := Get[Type]
        then:
            Set(Type, Current - Amount)
            return true

        if (not Get[Type]). Print("⚠️ WARNING: resources.Remove - Failed to get resource of type.")
        if (not Has[Type, Amount]). Print("⚠️ WARNING: resources.Remove - Player does not have enough of resource.")

        return false

    # Get Amount of Resource
    Get<public>(Type:resource_type)<transacts><decides>:float=
        Guy := Player.GetGuy[]
        Data := Guy.Data

        case(Type):
            resource_type.Rebirths => Data.Rebirths
            resource_type.Gems => Data.Gems
            resource_type.Gold => Data.Gold

    # Set Resource Data
    Set(Type:resource_type, Value:float):void=
        if (Guy := Player.GetGuy[], Data := Guy.Data):
            case(Type):
                resource_type.Rebirths => set Data.Rebirths = Value
                resource_type.Gold => set Data.Gold = Value
                resource_type.Gems => set Data.Gems = Value

            if (Data.Save[]) {}
            Guy.Events.ResourceChanged.Signal(Type, Value)

    GetRandomGoldGainPlayer()<transacts><decides>:gold_gain_message=
        (for (P:GoldGainMessages, not P.IsPlaying?). P)[0]

MakePlayerResources<public><constructor>(Player:player) := resources:
    Player := Player

ToString(Num:big_number):string=
    Num.Format()

gold_gain_message := class:
    Device:hud_message_device
    Player:player
    
    var IsPlaying:logic=false
    
    Play(Value:float):void=
        Device.Show(Player, guy_module.user_interface_module.text.Make("{Value.Format()}"), ?DisplayTime := 2.0)
        spawn. DelayedEnd()

    DelayedEnd()<suspends>:void=
        set IsPlaying = true
        Sleep(1.9)
        Device.Hide(Player)
        Sleep(0.2)
        set IsPlaying = false