using { /Fortnite.com/Devices }
using { /joycreative@fortnite.com/PetTycoon/verse/utils_module }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

gold_gain_message_device_tag := class(tag) {} 

random_gold_gain_manager<public> := class:
    var Devices:[]hud_message_device = array{}


messages<public> := class<concrete>(base_service):
    @editable Resources<public>:hud_message_device = hud_message_device{}
    @editable Achievement<public>:hud_message_device = hud_message_device{}
    @editable EggUnlock<public>:hud_message_device = hud_message_device{}

    # Gold gain
    var GoldGainDevices<public>:[]hud_message_device = array{}

    Init<override>():void=
        set GoldGainDevices = GetTaggedObjects(gold_gain_message_device_tag{}, hud_message_device)