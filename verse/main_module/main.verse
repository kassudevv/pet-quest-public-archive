using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org }
using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { utils_module }

analytics<public> := class<concrete>():
    @editable Hit<public>:accolades_device=accolades_device{} # d
    @editable HitBonus<public>:accolades_device=accolades_device{} # d
    @editable HitUltraBonus<public>:accolades_device=accolades_device{} # d

    @editable Hatch<public>:accolades_device=accolades_device{} # d
    @editable HatchGood<public>:accolades_device=accolades_device{} # d
    @editable HatchGreat<public>:accolades_device=accolades_device{} # d

    @editable Rebirth<public>:accolades_device=accolades_device{} # done
    @editable AreaUnlock<public>:accolades_device=accolades_device{} # done

    @editable QuestCompleted<public>:accolades_device=accolades_device{}#done
    @editable QuestAnalytics<public>:[]analytics_device = array{} # done

    @editable Bonus<public>:accolades_device=accolades_device{}

game<public> := class(creative_device):
    #* Services ----
    #? Player services
    @editable Guys<public>:guy_module.service = guy_module.service{}
    @editable Ftue<public>:ftue_module.Service.service = ftue_module.Service.service{}
    @editable Rewards<public>:reward_module.Service.service = reward_module.Service.service{}

    #? Farming services
    Breakables<public>:breakable_module.Service.service = breakable_module.Service.service{}
    @editable Areas<public>:area_module.Service.service = area_module.Service.service{}
    @editable Pets<public>:pet_module.Service.service = pet_module.Service.service{}
    @editable Eggs<public>:egg_module.Service.service = egg_module.Service.service{}
    @editable Analytics<public>:analytics=analytics{}

    #? Debug services
    @editable Debug<public>:debug = debug{}

    #? Get all Services to run
    GetServices():[]base_service = array{Breakables, Areas, Pets, Eggs, Guys, Ftue, Debug, Messages, Rewards}

    #* --------------

    # Misc Collections
    @editable Time<public>:utils_module.time_module.real_time = utils_module.time_module.real_time{}
    @editable SFX<public>:sfx = sfx{}
    @editable VFX<public>:vfx = vfx{}
    @editable Messages<public>:messages = messages{}

    # Global Events and Configs
    Events<public>:EventModule.main_events = EventModule.main_events{}
    Config<public>:config = config{}

    #? Main Entry Point
    OnBegin<override>()<suspends>:void={Sleep(0.0), spawn. Start()}
    OnEnd<override>():void=
        for (Guy:Guys.Guys). if. Guy.Data.Save[]

    #? Run Game Framework
    OnStart<public>:event() = event(){}
    Start()<suspends>:void=
        # Register self as Root Device
        Self.RegisterAsRootDevice()

        # Load services for lifecycle
        var Services:[]base_service = GetServices()

        # Run Initialize on each service asynchronously.
        ArraySync(Services, InitService)

        # Run Start on each service
        for (Service:Services) {spawn{Service.Start()}}

        # # Signal OnStart event
        OnStart.Signal()

# Helper function for ArraySync
InitService(Service:base_service)<suspends>:void=
    Service.Init()

