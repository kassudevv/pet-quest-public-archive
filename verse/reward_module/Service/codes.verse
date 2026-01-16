#? Code Redeems
# Calculate the per-player code for a given permission seed:
# Code = (( ( (fingerprint + permissionSeed) % 999979 ) * 982451 ) % 999979 ) % 89989 + 10000

code<public> := class<abstract>:
    Name<public>:string=""
    ExpiresAt<public>:?float=false

    Award<public>:type{_(:guy_module.guy):void}=AwardEmpty

    IsExpired<public>()<transacts>:logic=
        if (Date := ExpiresAt?):
            Now := GetGame().Time.GetDateAndTime()
            return logic{Now >= Date}
        false

    Verify<public>(Guy:guy_module.guy, Input:int):logic=
        # input is global key
        if (Redeemable := code_shared[Self]):
            return logic{Input = Redeemable.Code}

        # input is checksum
        else if (Redeemable := code_private[Self], Checksum := Redeemable.GetChecksum[Guy.Data.Fingerprint]):
            return logic{Checksum = Input}

        false

# Shared code
code_shared<public> := class(code):
    var Code<public>:int

# Per-player code
code_private<public> := class(code):
    # Permission Seed has to be within range of 1000..499999
    PermissionSeed<public>:int

    GetChecksum(Fingerprint:int)<transacts><decides>:int=
        Clean := Mod[Fingerprint + PermissionSeed, 999979]
        Hashed := Mod[Clean * 982451, 999979]
        FiveDigit := Mod[Hashed, 89989] + 10000