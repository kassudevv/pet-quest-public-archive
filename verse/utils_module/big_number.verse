using { /Verse.org/Simulation }

EditableCategory<localizes>:message="Big Number"

ExponentTip<localizes>:message="0 = -\n3 = K\n6 = M\n9 = B\n12 = T\n15 = Qa\n18 = Qi\n21 = Sx\n24 = Sp\n27 = Oc\n30 = No\n33 = De\n36 = U\n39 = D\n42 = Td\n45 = Qt\n48 = Qd\n51 = Sxd\n54 = Spd\n57 = Ocd\n60 = Nod\n63 = Dd\n66 = Tdd"
ValueTip<localizes>:message="0.0 <= x <= 10.0"

big_number<public> := struct<concrete><persistable>:
  @editable_slider(float):
    Categories := array{ EditableCategory }
    ToolTip := ValueTip
    MinValue := option { 0.0 }
    MaxValue := option { 1000.0 }
  Value<public>:float = 0.0
  @editable_slider(int):
    Categories := array{ EditableCategory }
    ToolTip := ExponentTip
    MinValue := option { 0 }
    MaxValue := option { 66 }
  Exponent<public>:int = 0

# Operator overrides
operator'+'<public>(A:big_number, B:big_number):big_number=
  CommonExponent:int = Max(A.Exponent, B.Exponent)

  NewValue:float =  (A.Value * Pow(10.0, (A.Exponent - CommonExponent) * 1.0)) +
                      (B.Value * Pow(10.0, (B.Exponent - CommonExponent) * 1.0))

  Normalize(big_number{Value := NewValue, Exponent := CommonExponent})

operator'-'<public>(A:big_number, B:big_number):big_number=
  CommonExponent:int = Max(A.Exponent, B.Exponent)
  NewValue:float =  (A.Value * Pow(10.0, (A.Exponent - CommonExponent) * 1.0)) -
                      (B.Value * Pow(10.0, (B.Exponent - CommonExponent) * 1.0))
  Normalize(big_number{Value := NewValue, Exponent := CommonExponent})

# MULTIPLY
operator'*'<public>(A:big_number, B:big_number):big_number=
  NewValue := A.Value * B.Value
  NewExponent := A.Exponent + B.Exponent

  Normalize(big_number{Value := NewValue, Exponent := NewExponent})

operator'*'<public>(A:big_number, B:float):big_number=
  NewValue := A.Value * B
  NewExponent := A.Exponent

  Normalize(big_number{Value := NewValue, Exponent := NewExponent})

# DIVIDE
operator'/'<public>(A:big_number, B:big_number):big_number=
  NewValue := A.Value / B.Value
  NewExponent := A.Exponent - B.Exponent

  Normalize(big_number{Value := NewValue, Exponent := NewExponent})

operator'/'<public>(A:big_number, B:float):big_number=
  NewValue := A.Value / B
  NewExponent := A.Exponent

  Normalize(big_number{Value := NewValue, Exponent := NewExponent})

# Calculate what percent A is of B, given as a float between 0 and 100.
PercentOf<public>(A:big_number, B:big_number):float=
  if (B.Value = 0.0):
      return 0.0  # Avoid division by zero.

  # Find the difference in exponents
  ExponentDifference := A.Exponent - B.Exponent

  # Adjust the value of A based on the exponent difference
  AdjustedAValue:float = A.Value * Pow(10.0, ExponentDifference * 1.0)

  # Calculate the percentage and return it
  Percentage:float = (AdjustedAValue / B.Value)
  Percentage

# Comparison methods
(A:big_number).Equals<public>(B:big_number)<decides><transacts>:void=
  A.Exponent = B.Exponent and A.Value = B.Value

(A:big_number).Greater<public>(B:big_number)<decides><transacts>:void=
  A.Exponent > B.Exponent or (A.Exponent = B.Exponent and A.Value > B.Value)

(A:big_number).GreaterOrEqual<public>(B:big_number)<decides><transacts>:void=
  A.Equals[B] or A.Greater[B]

(A:big_number).NotNull<public>()<decides><transacts>:void=
  A.Value > 0.0

# Formats a big_number into a string
Suffixes:[]string = array{
    "-",   # 1e0   (No suffix, used for numbers below 1,000)
    "K",   # 1e3   (Kilo)
    "M",   # 1e6   (Mega)
    "B",   # 1e9   (Billion)
    "T",   # 1e12  (Tera)
    "Qa",  # 1e15  (Peta)
    "Qi",  # 1e18  (Exa)
    "Sx",  # 1e21  (Zetta)
    "Sp",  # 1e24  (Yotta)
    "Oc",  # 1e27  (Octillion)
    "No",  # 1e30  (Nonillion)
    "De",  # 1e33  (Decillion)
    "U",   # 1e36  (Undecillion)
    "D",   # 1e39  (Duodecillion)
    "Td",  # 1e42  (Tredecillion)
    "Qt",  # 1e45  (Quattuordecillion)
    "Qd",  # 1e48  (Quindecillion)
    "Sxd", # 1e51  (Sexdecillion)
    "Spd", # 1e54  (Septendecillion)
    "Ocd", # 1e57  (Octodecillion)
    "Nod", # 1e60  (Novemdecillion)
    "Dd",  # 1e63  (Vigintillion)
    "Tdd"  # 1e66  (Unvigintillion)
};

(Number:big_number).Format<public>():string=
  if (Number.Value = 0). return "0"

  Normalized := NormalizeToNearestNumberSet(Number)

  # Under 1K should just return value as string.
  if (Normalized.Exponent < 3, Result := Floor[Normalized.Value]). return "{Result}"

  var String:string= "{Normalized.Value}"
  var TargetLength:int = Normalized.Value >= 100.0 and 3 or 4

  # Remove unnecessary zeroes from string.
  if:
    NewValue := String.Remove[TargetLength, String.Length]
    set String = NewValue

  # Add suffix to string.
  if:
    SuffixIndex:int = Quotient[Normalized.Exponent, 3]
    set String += Suffixes[SuffixIndex]

  String

# Takes a big_number, and converts it to ensure a single-digit whole-number component for the Value field
#   Ex)  14.2 * 10^2  will become 1.42 * 10^3
(Number:big_number).Normalize<public>():big_number=
  var NewExponent:int = Number.Exponent
  var NewValue:float = Number.Value

  if (NewValue <= 0.0):
      return NewResult := big_number{}

  loop:
      if (NewValue < 10.0):
          break
      set NewValue *= 0.1
      set NewExponent += 1

  loop:
      if (NewValue >= 1.0):
          break
      set NewValue *= 10.0
      set NewExponent -= 1

  Result := big_number:
      Value := NewValue
      Exponent := NewExponent

Normalize(Number:big_number):big_number=
  var NewExponent:int = Number.Exponent
  var NewValue:float = Number.Value

  if (NewValue <= 0.0):
      return NewResult := big_number{}

  loop:
      if (NewValue < 10.0):
          break
      set NewValue *= 0.1
      set NewExponent += 1

  loop:
      if (NewValue >= 1.0):
          break
      set NewValue *= 10.0
      set NewExponent -= 1

  Result := big_number:
      Value := NewValue
      Exponent := NewExponent

# Utility function for string formatting
# Takes a big_number, and converts it to ensure a 1,2 or 3 digit whole-number component for the Value field.
#  Ex)  1.42K or 14.2K or 142K are all valid
#       1420k is not valid, and should instead be 1.42M
NormalizeToNearestNumberSet(Number:big_number):big_number=
  var NewExponent:int = Number.Exponent
  var NewValue:float = Number.Value

  loop:
      if (Mod[NewExponent, 3] = 0):
          break

      set NewValue *= 10.0
      set NewExponent -= 1

  Result := big_number:
      Value := NewValue
      Exponent := NewExponent

(Number : big_number).NormalizeToNearestNumberSet<public>():big_number=
  NormalizeToNearestNumberSet(Number)

# Formatting for int and float values
(Number:float).Format<public>():string=
  var BigNum:big_number = big_number{Value := Number, Exponent := 0}
  set BigNum = Normalize(BigNum)
  BigNum.Format()

(Number:int).Format<public>():string=
  var BigNum:big_number = big_number{Value := Number * 1.0, Exponent := 0}
  set BigNum = Normalize(BigNum)
  BigNum.Format()