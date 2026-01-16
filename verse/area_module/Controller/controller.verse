using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Random }
using { /Verse.org/Simulation }

controller<public> := class(guy_module.guy_extension):
    MPCController:Assets.Models.Gameplay.AreaBorder.VF_AreaBorderMPCController= Assets.Models.Gameplay.AreaBorder.VF_AreaBorderMPCController{}
    Init<override>():void=
        if:
            Guy := Player.GetGuy[]
        then:
            if (PlayerUI := GetPlayerUI[Guy.Player]). PlayerUI.AddWidget(MPCController)
            spawn. ListenAreaChanges()

    ListenAreaChanges()<suspends>:void=
        if:
            Guy := Player.GetGuy[]
        then:
            var MPCPosition:float= Guy.Data.Areas[Guy.Data.Areas.Length-1]*1.0 or 0.0
            race:
                loop:
                    set MPCController.Position = MPCPosition+(GetRandomInt(10,90)*0.01)
                    Sleep(1.0)
                loop:
                    AreaId := Guy.Events.AreaUnlocked.Await()
                    set MPCPosition = AreaId*1.0
                loop:
                    Guy.Events.Rebirthed.Await()
                    set MPCPosition = 0.0
                Guy.Events.Left.Await()

    var CurrentArea<public>:?area_module.Service.breakable_area=false
    SetCurrentArea<public>(In:?area_module.Service.breakable_area):void=
        set CurrentArea = In
        if (Guy := Player.GetGuy[]):
            Guy.Events.CurrentAreaChanged.Signal(CurrentArea)

MakeController<public><constructor>(Player:player) := controller:
    Player := Player