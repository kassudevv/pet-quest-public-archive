using {verse.guy_module}

main_events<public> := class:
    # Player loaded in for the first time or left the game
    PlayerJoined<public>:signal(guy) = signal(guy){}
    PlayerLeft<public>:signal(guy) = signal(guy){}

