using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }

debug<public> := class<concrete>(base_service):
    @editable AwardGold:button_device = button_device{}

    @editable OpenPet:button_device = button_device{}
    @editable AddPet:button_device = button_device{}
    @editable RemovePet:button_device = button_device{}
    @editable MiscPet:button_device = button_device{}

    Init<override>()<suspends>:void=
        AwardGold.InteractedWithEvent.Subscribe(OnAwardGold)

        OpenPet.InteractedWithEvent.Subscribe(OnOpenPet)
        AddPet.InteractedWithEvent.Subscribe(OnAddPet)
        RemovePet.InteractedWithEvent.Subscribe(OnRemovePet)
        MiscPet.InteractedWithEvent.Subscribe(OnMiscPet)

        Time := utils_module.time.DateToUnixTimestamp(2025, 12, 25, 12, 0, 0)
        Print("Time: {Time}")
        

    OnOpenPet(Agent:agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            Guy.UI.PetInventory.Enable()

    OnAddPet(Agent:agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            GetGame().Time.AddDebugTimeOffsetDays(1)

    OnRemovePet(Agent:agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            Guy.UI.PetInventory.Enable()

    OnMiscPet(Agent:agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
        then:
            Guy.UI.Codes.Enable()


    GetMessage<public><localizes>(Gold:int):message="{Gold}"

    OnAwardGold(Agent:agent):void=
        if:
            Player := player[Agent]
            Guy := Player.GetGuy[]
            Game := GetGame()
        then:
            Guy.Resources.Award(guy_module.resource_type.Gold, GetRandomInt(100, 9999)*1.0)