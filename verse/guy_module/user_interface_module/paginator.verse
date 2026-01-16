using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }

paginator<public> := class():
    Player<public>:player

    var ItemsPerPage:int = 5
    var CurrentPage:int = 1
    var AmountPages:int = 1

    # Current Page changed event
    PageUpdated:signal(tuple()) = signal(tuple()){}

    # Page location
    var TextBlock:text_block = text_block{}
    SetInfoTextBlock<public>(InTextBlock : text_block):void=set TextBlock = InTextBlock

    # Get Paginator Text
    GetPaginatorText():message=text.Make("Page {CurrentPage}/{AmountPages}")

    # Utility
    Paginate(AllItems:[]t where t:type):[]t =
        if (CurrentPage < 1 or ItemsPerPage <= 0). return array{}

        StartIndex := (CurrentPage - 1) * ItemsPerPage

        if (StartIndex >= AllItems.Length). return array{}
        
        EndIndex := StartIndex + ItemsPerPage

        return AllItems.Slice[StartIndex, Min(EndIndex, AllItems.Length)] or array{}

    SetPages<public>(Amount : int):void=
        set CurrentPage = 1
        set AmountPages = Amount

        TextBlock.SetText(GetPaginatorText())

    IsInRange(Page : int)<transacts><decides>:void=
        1 <= Page
        Page <= AmountPages

    Forward():void=
        if:
            IsInRange[CurrentPage + 1]
            Guy := Player.GetGuy[]
        then:
            set CurrentPage += 1

            TextBlock.SetText(GetPaginatorText())
            PageUpdated.Signal()

    Back():void=
        if:
            IsInRange[CurrentPage - 1]
            Guy := Player.GetGuy[]
        then:
            set CurrentPage -= 1

            TextBlock.SetText(GetPaginatorText())
            PageUpdated.Signal()