using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /Verse.org/Colors/NamedColors }
using { /Verse.org/Simulation }
using { EventModule }
using { utils_module }
using { guy_module.user_interface_module }

rebirths<public> := class(user_interface):
    Interactive<override>:logic = true
    
    BlurBackground<override>:logic = true
    Sunburst<override>:logic = true
    
    var IsInAnimation<public>:logic=false
    RebirthAnimationWidget:Assets.UI.Rebirths.WBP_RebirthAnimation = Assets.UI.Rebirths.WBP_RebirthAnimation{}
    ListenRebirthButton(Button:button_loud)<suspends>:void=
        loop:
            Button.OnClick().Await()

            if (Guy := Player.GetGuy[], not IsInAnimation?):
                if (not Guy.Data.Areas.Find[25]):
                    spawn. Guy.UI.Notifications.PlayMessage("You have to unlock all areas first! How did you get here?", ?IsError := true)
                    return

                if (not Guy.Data.QuestId >= 93):
                    spawn. Guy.UI.Notifications.PlayMessage("You have to complete all quests first!", ?IsError := true)
                    return

                set IsInAnimation = true
                Disable()

                spawn. Guy.UI.Notifications.PlayMessage("Congrats on your Rebirth #{Round[Guy.Data.Rebirths+1.0] or 1}!")
                
                set Guy.Data.Rebirths += 1.0
                set Guy.Data.Areas = array{0}
                set Guy.Data.QuestId = 0
                Guy.Resources.Set(resource_type.Gold, 0.0) # this function saves the data, no need for extra save call
                Guy.Events.Rebirthed.Signal()
                
                GetGame().Analytics.Rebirth.Award(Guy.Player)
                GetGame().SFX.QuestCompleted.Play(Player)
                
                Eggs := GetGame().Eggs
                if:
                    Egg := Eggs.GetDefinitionFromName["Rebirth Egg"]
                    Pet := Eggs.RollEgg[Guy, Egg]
                then:
                    spawn. Eggs.DelayedAwardPet(Guy, Pet)
                    spawn. Guy.Eggs.PlayEggUnlockAnimationWithParams(Egg, Pet, ?IsNew := logic{not Guy.Inventory.Pets.Has[Pet.Id]})
    
                    Sleep(3.0)

                    GetGame().SFX.Success.Play(Player)

                    Target := luf_xform{Translation := luf_vec3{Left := 10526.877008, Up := 337.428471, Forward := -3528.46586}}
                    if (Player.TeleportEntity[Target]) {}

                    if (Player.IsActive[], PlayerUI := GetPlayerUI[Player]):
                        set RebirthAnimationWidget.VRebirthText = text.Make("Rebirth {Round[Guy.Data.Rebirths] or 1}")
                        set RebirthAnimationWidget.VPetIcon = Pet.Icon
                        PetChance := (for (R:Egg.Rewards, R.Pet = Pet.Name). R.Chance)[0] or 1.0
                        set RebirthAnimationWidget.VPetName = text.Make("{Pet.Name} ({Round[PetChance*100.0] or 100}%)")

                        PlayerUI.AddWidget(RebirthAnimationWidget)
                        set RebirthAnimationWidget.VPlayAnimIncr += 1.0
                        Sleep(10.5)
                        PlayerUI.RemoveWidget(RebirthAnimationWidget)
                        set IsInAnimation = false

                        Guy.Ftue.StartListeningQuests()

    Build<override>():void=
        Canvas := canvas{}

        RebirthButton := button_loud{DefaultText := text.Make("Rebirth!")}
        spawn. ListenRebirthButton(RebirthButton)
            
        InnerContainer := overlay:
            Slots := array:
                overlay_slot:
                    HorizontalAlignment := horizontal_alignment.Fill
                    VerticalAlignment:=vertical_alignment.Fill
                    Padding := Margin(48)
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                HorizontalAlignment := horizontal_alignment.Fill
                                VerticalAlignment:=vertical_alignment.Fill
                                Widget := Assets.UI.Rebirths.VF_RebirthInfoContent{}
                            stack_box_slot:
                                # Padding := margin{Top := 16.0}
                                HorizontalAlignment := horizontal_alignment.Center
                                VerticalAlignment:=vertical_alignment.Center
                                Widget := RebirthButton


        Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.5}, Maximum := vector2{X := 0.5, Y := 0.5}}
        Alignment := vector2{X:=0.5,Y:=0.5}
        Panel := panel{Parent := Self, Content := InnerContainer, Anchors := Anchors, Alignment := Alignment, SizeToContent := true, Title := (Assets.UI.Icons.Rebirth_Outline_64, "REBIRTHS!")}

        Canvas.AddWidget(Panel.Build())

        set _Canvas = option. Canvas

MakeRebirthsUI<public><constructor>(Player:player) := rebirths:
    Player := Player