using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

egg_component<public> := class<final_super>(component):
    @editable var<public> EggId:int=0
    @editable var<public> PriceTagEntity:entity=entity{}
    @editable var<public> InteractEntity:entity=entity{}
    @editable var<public> InfoEntity:entity=entity{}
  
    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()

    OnSimulate<override>()<suspends>:void=block{}

egg_purchase_interactable_component<public> := class<final_super>(interactable_component):
    InteractTextAllowed<localizes>:message="👈 OPEN!"
    InteractTextDisallow<localizes>:message="❌ LOCKED."

    InteractMessage<override>(Agent:agent)<decides><reads> : message = if (player[Agent].GetGuyNoTransacts[].Data.Areas.Find[AreaId]). InteractTextAllowed else. InteractTextDisallow

    var AreaId<public>:int=0
    CanInteract<override>(Agent:agent)<decides><reads> : void = true
        # player[Agent].GetGuyNoTransacts[].Data.Areas.Find[AreaId]

    var<public> Egg:egg_definition = egg_definition{}

    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()

    OnSimulate<override>()<suspends>:void = block{}
