using { /Verse.org/Random }
using { /Verse.org/Simulation }
using { utils_module }

# Persistence
var PlayerDataMap:weak_map(player, persistable_player_data) = map{}

Versions := module:
    CurrentVersion<public>:int = 1
    
pet_data<public> := struct<persistable>:
  # How many of this pet the player owns.
  Owned<public>:int
  
  # How many of this pet the player has equipped. Amount Stored = Owned - Equipped
  Equipped<public>:int

data<public> := class(guy_extension):
  Save<public>()<transacts><decides>:void = Self._Save[]
  Dispose<override>():void = if (Save[]) {}

  # 1. Add Here
  var Version<public>:int
  var Fingerprint<public>:int

  #? Unlocked Pets and Areas
  var Areas<public>:[]int
  var Pets<public>:[int]pet_data

  #? Player Currencies
  var Rebirths<public>:float
  var Gold<public>:float
  var Gems<public>:float

  var QuestId<public>:int
  var QuestProgress<public>:int

  #? Misc
  var AutoHatchEnabled<public>:logic
  var PetsDiscovered<public>:[]int=array{}
  var CodesRedeemed<public>:[]string=array{}
  var MusicEnabled<public>:logic

  #? Stats
  var EggsHatched<public>:float=0.0
  var GoldEarned<public>:float=0.0
  var Playtime<public>:float=0.0

persistable_player_data := class<final><persistable>:
  # 2. Add Here
  Version:?int = false
  Fingerprint:?int = false

  Areas:?[]int = false
  Pets:?[int]pet_data=false

  Rebirths:?float = false
  Gold:?float = false
  Gems:?float = false

  QuestId:?int = false
  QuestProgress:?int = false

  EggsHatched:?float=false
  AutoHatchEnabled:?logic = false
  PetsDiscovered:?[]int=false
  CodesRedeemed:?[]string=false
  MusicEnabled:?logic = false
  GoldEarned:?float=false
  Playtime:?float=false

(Data:data)._Save()<transacts><decides>:void=
  PersistablePlayerData := persistable_player_data:
    # 3. Add Here
    Version := option. Data.Version
    Fingerprint := option. Data.Fingerprint

    Areas := option. Data.Areas
    Pets := option. Data.Pets

    Rebirths := option. Data.Rebirths
    Gold := option. Data.Gold
    Gems := option. Data.Gems

    QuestId := option. Data.QuestId
    QuestProgress := option. Data.QuestProgress

    EggsHatched := option. Data.EggsHatched
    AutoHatchEnabled := option. Data.AutoHatchEnabled
    PetsDiscovered := option. Data.PetsDiscovered
    CodesRedeemed := option. Data.CodesRedeemed
    MusicEnabled := option. Data.MusicEnabled
    GoldEarned := option. Data.GoldEarned
    Playtime := option. Data.Playtime

  Data.Player.IsActive[]
  FitsInPlayerMap[PersistablePlayerData]
  set PlayerDataMap[Data.Player] = PersistablePlayerData

MakePlayerData(Player:player):data=
  Raw := PlayerDataMap[Player] or persistable_player_data{}

  data:
    Player := Player

    # 4. Add Here
    Version := Raw.Version? or Versions.CurrentVersion
    Fingerprint := Raw.Fingerprint? or GenerateFingerprint()

    Areas := Raw.Areas? or array{0}
    Pets := Raw.Pets? or map{}
  
    Rebirths := Raw.Rebirths? or 0.0
    Gold := Raw.Gold? or 0.0
    Gems := Raw.Gems? or 0.0

    QuestId := Raw.QuestId? or 0
    QuestProgress := Raw.QuestProgress? or 0

    EggsHatched := Raw.EggsHatched? or 0.0
    AutoHatchEnabled := Raw.AutoHatchEnabled? or false
    PetsDiscovered := Raw.PetsDiscovered? or array{}
    CodesRedeemed := Raw.CodesRedeemed? or array{}
    MusicEnabled := Raw.MusicEnabled? or true
    GoldEarned := Raw.GoldEarned? or 0.0
    Playtime := Raw.Playtime? or 0.0

GenerateFingerprint():int=
  Timestamp := Round[GetSecondsSinceEpoch() * 1000.0] or GetRandomInt(0, 999999999999)
  Fingerprint := Timestamp + GetRandomInt(0,999999999999)