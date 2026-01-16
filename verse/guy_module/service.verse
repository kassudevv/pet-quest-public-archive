using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }

teleport_targets<public> := class<concrete>():
    @editable Spawn:?subtype(entity) = false

bonus_tag := class(tag) {}

service<public> := class(main_module.base_service):
    # Set to FFA. Catches all player respawns, more reliable than player spawn pads.
    @editable TeamSettingsAndInventoryDevice:team_settings_and_inventory_device = team_settings_and_inventory_device{}
    @editable SignalGranter:item_granter_device = item_granter_device{}

    @editable SignalRemoteGold:signal_remote_manager_device=signal_remote_manager_device{}
    @editable SignalRemotePurple:signal_remote_manager_device=signal_remote_manager_device{}
    @editable SignalRemoteBlue:signal_remote_manager_device=signal_remote_manager_device{}

    @editable Teleports:teleport_targets=teleport_targets{}
    @editable PetIndexButton:button_device=button_device{}
    @editable RebirthShrineButton:button_device=button_device{}
    @editable ToggleMusicButton:button_device=button_device{}
    @editable BonusBP:creative_prop_asset=DefaultCreativePropAsset

    # All Guys
    var Guys<public>:[player]guy = map{}

    # Lifecycle
    Start<override>():void=
        # Catch joining players
        Playspace := GetGame().GetPlayspace()
        # Playspace.PlayerAddedEvent().Subscribe(PlayerAddingEvent)

        # Catch exiting players
        Playspace.PlayerRemovedEvent().Subscribe(OnPlayerLeft)

        # Catch existing players
        for (Player:Playspace.GetPlayers()):
            spawn. AwaitPlayerAddingEvent(Player)

        # Catch respawns
        Spawners := FindCreativeObjectsWithTag(device_identifier_tags.spawner{})
        for (SpawnerObj : Spawners):
            if (Spawner := player_spawner_device[SpawnerObj]):
                Spawner.SpawnedEvent.Subscribe(OnPlayerSpawned)

        PetIndexButton.InteractedWithEvent.Subscribe(OpenPetIndex)
        RebirthShrineButton.InteractedWithEvent.Subscribe(OpenRebirthShrine)
        ToggleMusicButton.InteractedWithEvent.Subscribe(ToggleMusic)

        spawn. SetupBonuses()

    SetupBonuses()<suspends>:void=
        var AmountPlayers:int=Guys.Length
        MIN_PLAYERS:=2
        loop:
            if (AmountPlayers >= MIN_PLAYERS). break
            GetGame().Events.PlayerJoined.Await()
            set AmountPlayers += 1
        
        BonusLocations := GetTaggedObjects(bonus_tag{}, creative_prop)
        for (L:BonusLocations, L.IsValid[], T:=L.GetTransform()):
            if (Prop := SpawnProp(BonusBP, T)(0)?) {}
            spawn. ListenForBonusInteract(T)
    ListenForBonusInteract(T:xyz_xform)<suspends>:void=
        Bonus := GetGame().Analytics.Bonus
        loop:
            for (Guy:Guys, Fort := Guy.Player.SafeFortCharacter[], Pos := Fort.GetTransform()):
                Dist := FastDistance(T.Translation ,Pos.Translation)
                if (Dist < 128.0):
                    Bonus.Award(Guy.Player)
            Sleep(0.333)

    ToggleMusic(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[]):
            Guy.ToggleMusic()

    OpenPetIndex(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[]):
            AmountPets := GetGame().Pets.PetDefinitions.Length
            Discovered := Guy.Data.PetsDiscovered.Length
            
            if:
                Rate:float= (Discovered*1.0)/(AmountPets*1.0)
                AsNum := Round[Rate*100.0]
            then:
                spawn. Guy.UI.Notifications.PlayMessage("You have discovered {AsNum}% ({Discovered}/{AmountPets}) of all pets!", ?Duration := 10.0)
                Guy.UI.Stats.Enable()

    OpenRebirthShrine(Agent:agent):void=
        if (Guy := player[Agent].GetGuy[], not Guy.UI.Rebirths.IsInAnimation?):
            Guy.UI.Rebirths.Enable()

    # Public Methods
    Get<public>(Player:player)<decides><transacts>:guy=
        Guys[Player]

    # Private Methods
    #? RESPAWN
    OnPlayerSpawned<private>(Agent:agent):void=
        if:
            MyGuy := player[Agent].GetGuy[]
            Fort := MyGuy.Player.SafeFortCharacter[]
        then:
            utils_module.Info("Player Respawned")

        if (Player := player[Agent], not Player.GetGuy[]):
            spawn. AwaitPlayerAddingEvent(Player)

    #? JOINING
    PlayerAddedEvent:event(player)=event(player){}
    OnPlayerAdded<private>(Player:player):void=
        if (Guys[Player]). return

        Guy := MakeGuy(Player)
        if. set Guys[Player] = Guy

        Guy.Init()
        PlayerAddedEvent.Signal(Player)

    AwaitPlayerAddingEvent<private>(Player:player)<suspends>:void=
        Playspace := GetGame().GetPlayspace()

        race:
            loop:
                if (Fort := Player.SafeFortCharacter[]) {return OnPlayerAdded(Player)}
                Sleep(0.0)
            loop:
                PlayerLeaving := Playspace.PlayerRemovedEvent().Await()
                if (PlayerLeaving = Player) {break}
            loop:
                PlayerAdded := PlayerAddedEvent.Await()
                if (PlayerAdded = Player) {break}
    #? LEAVING
    OnPlayerLeft<private>(Player:player):void=
        utils_module.Info("Player Left")

        if (MyGuy := Guys[Player]):
            MyGuy.Dispose()

            var NewGuysMap:[player]guy = map{}
            for (Key -> Value:Guys, Key <> Player):
                set NewGuysMap = ConcatenateMaps(NewGuysMap, map{Key => Value})
            set Guys = NewGuysMap