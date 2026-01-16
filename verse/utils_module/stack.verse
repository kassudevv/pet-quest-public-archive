stack<public>(t:type) := class<computes>:
    #? Internal Variables
    Values<internal>:[]t = array{}
    Len<internal>:int = 0

    #? Public Methods
    # Returns the item from the top of the stack
    Top<public>()<computes><decides>:t =
        Values[Len - 1]

    # Adds an item to the top of the stack
    Push<public>(Value:t)<computes>:stack(t) =
        stack(t):
            Values := Values + array{Value}
            Len := Len + 1

    # Removes the item from the top of the stack
    Pop<public>()<computes>:stack(t) =
        stack(t):
            Values := Values.Slice[0, Len - 1] or array{}
            Len := Len - 1

    # Returns the number of items currently in the stack
    Length<public>()<computes>:int = Len