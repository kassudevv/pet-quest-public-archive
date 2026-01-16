using { /Verse.org/Simulation }
using { config_module }

var ConfigWeakMap<internal>:weak_map(session, config) = map{}

config<public> := class():
    UI<public>:ui = ui{}

GetConfig<public>()<transacts>:config=
    Session := GetSession()

    if (Config := ConfigWeakMap[Session]) {Config}
    else {
        NewConfig := config{}
        if. set ConfigWeakMap[Session] = NewConfig
        NewConfig
    }
