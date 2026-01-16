using { /Verse.org }
using { /Verse.org/Native }
using { /Verse.org/SceneGraph }
using { /Verse.org/Simulation }

area_component<public> := class<final_super>(component):
    @editable var<public> AreaId:int=0
    @editable var<public> AreaHintEntity:entity=entity{}
    @editable var<public> AreaPriceEntity:entity=entity{}
    @editable var<public> PurchaseEntity:entity=entity{}
    @editable var<public> WallEntity:entity=entity{}
  
    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()

    OnSimulate<override>()<suspends>:void=block{}

# A Verse-authored component that can be added to entities
area_purchase_interactable_component<public> := class<final_super>(interactable_component):    
    InteractTextAllowed<localizes>:message="👈 PURCHASE!"
    InteractTextDisallow<localizes>:message="❌ NOT ENOUGH GOLD!"

    InteractMessage<override>(Agent:agent)<decides><reads> : message =
        if (player[Agent].GetGuyNoTransacts[].Data.Gold >= Price) then InteractTextAllowed else InteractTextDisallow

    var<public> AreaId:int = -1
    var<public> Price:float = -1.0

    CanInteract<override>(Agent:agent)<decides><reads> : void =
        not AreaId = -1

        Guy := player[Agent].GetGuyNoTransacts[]
        not Guy.Data.Areas.Find[AreaId]

    OnBeginSimulation<override>():void =
        (super:)OnBeginSimulation()

    OnSimulate<override>()<suspends>:void = block{}