using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { EventModule }
using { utils_module }

guy<public> := class<unique>():
    Player<public>:player

    UI<public>:ui
    Data<public>:data
    Resources<public>:resources
    Pets<public>:pet_module.Controller.controller
    Breakables<public>:breakable_module.Controller.breakable_controller
    Inventory<public>:inventory
    Areas<public>:area_module.Controller.controller
    Eggs<public>:egg_module.Controller.controller
    Ftue<public>:ftue_module.Controller.controller

    Maid:maid = maid{}
    Events<public>:guy_events

    GetExtensions():[]guy_extension = array{UI, Data, Inventory, Resources, Pets, Eggs, Breakables, Areas, Ftue}

    Init():void=
        Print("Initializing Player!")

        Extensions := GetExtensions()
        for (Extension:Extensions) {Extension.Init()}

        InitMusic()
        InitSignals()
        spawn. TrackPlaytime()

        GetGame().Events.PlayerJoined.Signal(Self)
        Self.Events.Joined.Signal(Self)

    TrackPlaytime()<suspends>:void=
        var LastCheck:float= GetSimulationElapsedTime()
        race:
            loop:
                Sleep(1.0)
                Diff := LastCheck.GetDeltaTime()
                set LastCheck = GetSimulationElapsedTime()
                set Data.Playtime += Diff
            Events.Left.Await()

    ## MUSIC
    MusicStateChanged:event()=event(){}
    IdToTrackLength:[int]float = map{0 => 122.0, 1 => 93.0, 2 => 165.0}
    var CurrentTrackIdx:int=0
    InitMusic():void=if (Data.MusicEnabled?). spawn. LoopMusic()
    LoopMusic()<suspends>:void=
        Tracks := GetGame().SFX.Soundtracks
        
        race:
            loop:
                if (Track := Tracks[CurrentTrackIdx], Length := IdToTrackLength[CurrentTrackIdx]):
                    Track.Play(Player)
                    Sleep(Length)
                    set CurrentTrackIdx += 1
                else:
                    set CurrentTrackIdx = 0
                    Sleep(1.0)
            Events.Left.Await()
            MusicStateChanged.Await()

    ToggleMusic():void=
        ShouldPlay := logic{not Data.MusicEnabled?}

        set Data.MusicEnabled = ShouldPlay
        if. Data.Save[]

        MusicStateChanged.Signal()

        if (ShouldPlay?):
            spawn. UI.Notifications.PlayMessage("Enabled music!")
            spawn. LoopMusic()
        else:
            spawn. UI.Notifications.PlayMessage("Disabled music.", ?IsError := true)
            for (MusicPlayer:GetGame().SFX.Soundtracks). MusicPlayer.Stop(Player) 
    ####

    InitSignals():void=
        GuyService := GetGame().Guys
        GuyService.SignalGranter.GrantItem(Player)
        GuyService.SignalGranter.RestockItems()

        DeviceToCallback:[]tuple(signal_remote_manager_device, type{_():void}) = array:
            (GuyService.SignalRemoteGold, OnUseGoldRemote),
            (GuyService.SignalRemotePurple, OnUsePurpleRemote),
            (GuyService.SignalRemoteBlue, OnUseBlueRemote)

        for (T:DeviceToCallback). spawn. ListenForSignal(T(0), T(1))
        
    ListenForSignal(Device:signal_remote_manager_device, Callback:type{_():void})<suspends>:void=
        loop:
            Agent := Device.PrimarySignalEvent.Await()   
            if (Agent = agent[Player]). Callback()

    OnUseGoldRemote():void=
        if (Guy := Player.GetGuy[]):
            if (Guy.Eggs.IsInAnimation?). return
            if (Guy.UI.Rebirths.IsInAnimation?). return

            if (Guy.Data.QuestId < 8):
                spawn. Guy.UI.Notifications.PlayMessage("Complete the tutorial to access this feature!", ?IsError := true)
                return
            
            Guy.UI.PetInventory.Enable()

    OnUsePurpleRemote():void=
        if (Guy := Player.GetGuy[], Pet := GetGame().Pets.PetDefinitions[0], Egg := GetGame().Eggs.EggDefinitions[0]):
            if (Guy.Eggs.IsInAnimation?). return
            if (Guy.UI.Rebirths.IsInAnimation?). return

            if (Guy.Data.QuestId < 9):
                spawn. Guy.UI.Notifications.PlayMessage("Complete the tutorial to access this feature!", ?IsError := true)
                return


            Guy.UI.Teleports.Enable()

    OnUseBlueRemote():void=
        if (Guy := Player.GetGuy[], Pet := GetGame().Pets.PetDefinitions[0], Egg := GetGame().Eggs.EggDefinitions[0]):
            if (Guy.Eggs.IsInAnimation?). return
            if (Guy.UI.Rebirths.IsInAnimation?). return

            if (Guy.Data.QuestId < 9):
                spawn. Guy.UI.Notifications.PlayMessage("Complete the tutorial to access this feature!", ?IsError := true)
                return

            Guy.UI.Menu.Enable()

    Dispose():void=
        Print("Disposing Player!")

        if. Data.Save[]

        Extensions := GetExtensions()
        for (Extension:Extensions) {Extension.Dispose()}

        Maid.Cleanup()

        GetGame().Events.PlayerLeft.Signal(Self)
        Events.Left.Signal(Self)

# Guy Extension Helper Class with Lifecycle
guy_extension<public> := class<abstract>:
    Player<public>:player
    Init<public>():void = block{}
    Dispose<public>():void = block{}

# Make Guy
MakeGuy<constructor>(Player:player) := guy:
    Player := Player

    Data := MakePlayerData(Player)
    UI := MakePlayerUI(Player)
    Resources := MakePlayerResources(Player)
    Pets := pet_module.Controller.MakePlayerPetController(Player)
    Breakables := breakable_module.Controller.MakePlayerBreakables(Player)
    Inventory := MakePlayerInventory(Player)
    Areas := area_module.Controller.MakeController(Player)
    Eggs := egg_module.Controller.MakeController(Player)
    Ftue := ftue_module.Controller.MakeController(Player)
    
    Events := guy_events{}