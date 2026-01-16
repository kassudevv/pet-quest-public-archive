using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }

pin_editable := struct<concrete>:
    @editable Name:string = ""
    @editable Pin:int = 999999

service<public> := class(main_module.base_service):
    @editable MenuButton:button_device=button_device{}

    OpenMenu(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[]):
            Guy.UI.Codes.Enable()

    Init<override>():void=
        MenuButton.InteractedWithEvent.Subscribe(OpenMenu)

    GetCodes<public>():[]code=
        Codes := array:
            # Shared Public Codes
            code_shared:
                Name := "Christmas Gift Pack"
                Code := 122425
                ExpiresAt := option. utils_module.time.DateToUnixTimestamp(2026, 1, 26, 23, 59, 59)
                Award := AwardChristmasPack

            # Unique Player Codes
            code_private:
                Name := "MEGA Supporter Pack"
                PermissionSeed := 2023
                Award := AwardVIP

        Codes

AwardEmpty(Guy:guy_module.guy):void=Print("Code redeem function is missing.")

AwardVIP(Guy:guy_module.guy):void=
    if (MEGAMiner := GetGame().Pets.NameToPet["MEGA Spidey"]). Guy.Inventory.Pets.AwardPet(MEGAMiner.Id)
    Guy.Resources.Award(guy_module.resource_type.Gold, 1000000.0)

    spawn. Guy.UI.Notifications.PlayMessage("Thanks for playing & stay awesome! - Pet Quest Developers", ?Duration := 15.0)

AwardChristmasPack(Guy:guy_module.guy):void=
    if (Pet := GetGame().Pets.NameToPet["Chick"]). Guy.Inventory.Pets.AwardPet(Pet.Id)
    Guy.Resources.Award(guy_module.resource_type.Gold, 100000.0)
    
    spawn. Guy.UI.Notifications.PlayMessage("Wishing you a Merry Christmas and a Happy New Year! - Pet Quest Developers", ?Duration := 15.0)