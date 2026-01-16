using { /UnrealEngine.com/Temporary/Diagnostics }
using { utils_module.time_module }

# Main Game Config
config<public> := class():
    GetCodes<public>():[]code=array:
        code_shared:
            Name := "Starter Pack"
            Code := 13516
            ExpiresAt := option. MakeDateAndTime(2025, 7, 30, 23, 59, 0.0)
            Redeem := RedeemStarterPack
        code_private:
            Name := "VIP"
            PermissionSeed := 2023
            Redeem := RedeemVIP


#? Code Redeems
# Calculate the per-player code for a permission seed:
# Code = (( ( (fingerprint + permissionSeed) % 999979 ) * 982451 ) % 999979 ) % 89989 + 10000

code<public> := class<abstract>:
    Name<public>:string=""
    ExpiresAt<public>:?date_and_time=false

    Redeem<public>:type{_(:guy_module.guy):void}=RedeemEmpty

    IsExpired<public>()<transacts>:logic=
        if (Date := ExpiresAt?):
            Now := GetGame().Time.GetDateAndTime()
            return logic{Now >= Date.GetTotalSeconds()}
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
    Code<public>:int

# Per-player code
code_private<public> := class(code):
    # Permission Seed has to be within range of 1000..499999
    PermissionSeed<public>:int

    GetChecksum(Fingerprint:int)<transacts><decides>:int=
        Clean := Mod[Fingerprint + PermissionSeed, 999979]
        Hashed := Mod[Clean * 982451, 999979]

        # Map into 5-digit range with a prime modulus for uniformity
        FiveDigit := Mod[Hashed, 89989] + 10000

RedeemEmpty(Guy:guy_module.guy):void=Print("Code redeem function is missing.")
RedeemVIP(Guy:guy_module.guy):void=Print("Redeemed VIP!")
RedeemStarterPack(Guy:guy_module.guy):void=Print("Redeemed starter pack!")
