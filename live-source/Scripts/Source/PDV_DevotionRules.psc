Scriptname PDV_DevotionRules

; PDV 2.0 rebuild -- stateless leaf utilities extracted from PDV__ManagerQuest.
; Every function here is Global (no instance state); callers invoke them as
; PDV_DevotionRules.<Name>(...). See references/authoring/PDV_2_0RegionMap.json
; (module RULES) and the retirement ledger for the full extraction contract.

; @module: RULES
Int Function AbsInt(Int value) Global
    if value < 0
        return 0 - value
    endIf

    return value
EndFunction

; @module: RULES
Float Function MaxFloat(Float firstValue, Float secondValue) Global
    if secondValue > firstValue
        return secondValue
    endIf
    return firstValue
EndFunction

; @module: RULES
String Function SeverityLabel(Int severity) Global
    if severity <= 0
        return "comfortable"
    elseIf severity == 1
        return "mild hardship"
    elseIf severity == 2
        return "moderate hardship"
    endIf
    return "severe hardship"
EndFunction

; @module: RULES
String Function JournalDayToFictionDate(Int gameDay) Global
    String[] months = new String[12]
    months[0] = "Morning Star"
    months[1] = "Sun's Dawn"
    months[2] = "First Seed"
    months[3] = "Rain's Hand"
    months[4] = "Second Seed"
    months[5] = "Midyear"
    months[6] = "Sun's Height"
    months[7] = "Last Seed"
    months[8] = "Hearthfire"
    months[9] = "Frostfall"
    months[10] = "Sun's Dusk"
    months[11] = "Evening Star"
    Int dayOfYear = gameDay - ((gameDay / 360) * 360)
    if dayOfYear < 0
        dayOfYear = 0
    endIf
    Int monthIndex = dayOfYear / 30
    if monthIndex >= 12
        monthIndex = 11
    endIf
    Int dayOfMonth = dayOfYear - (monthIndex * 30) + 1
    return months[monthIndex] + " " + dayOfMonth
EndFunction

; @module: RULES
Bool Function StringMatchesAt(String sourceText, String needleText, Int startIndex) Global
    Int needleLength = StringUtil.GetLength(needleText)
    Int needleIndex = 0
    while needleIndex < needleLength
        if StringUtil.GetNthChar(sourceText, startIndex + needleIndex) != StringUtil.GetNthChar(needleText, needleIndex)
            return False
        endIf
        needleIndex += 1
    endWhile

    return True
EndFunction

; @module: RULES
Int Function CountSetBits(Int maskValue) Global
    Int count = 0
    Int remaining = maskValue
    if remaining >= 4
        count += 1
        remaining -= 4
    endIf
    if remaining >= 2
        count += 1
        remaining -= 2
    endIf
    if remaining >= 1
        count += 1
    endIf
    return count
EndFunction

; @module: RULES
Bool Function IsEncodedDayWithinWindow(Int encodedDay, Int currentDay, Int windowDays) Global
    if encodedDay <= 0
        return False
    endIf

    Int dayValue = encodedDay - 1
    Int dayDelta = currentDay - dayValue
    if dayDelta < 0
        return False
    endIf

    return dayDelta < windowDays
EndFunction

; @module: RULES
Bool Function IsLocationFromFile(Location loc, Int sourceFormId, String pluginName) Global
    if !loc
        return False
    endIf

    Location expectedLoc = Game.GetFormFromFile(sourceFormId, pluginName) as Location
    if !expectedLoc
        return False
    endIf

    return loc == expectedLoc
EndFunction

; @module: RULES
Int Function NeedToSeverity(GlobalVariable needGlobal) Global
    if !needGlobal
        return 0
    endIf

    Float needValue = needGlobal.GetValue()
    if needValue >= 75.0
        return 3
    elseIf needValue >= 50.0
        return 2
    elseIf needValue >= 25.0
        return 1
    endIf
    return 0
EndFunction

; @module: RULES
Int Function MaxSeverity(Int leftValue, Int rightValue) Global
    if leftValue >= rightValue
        return leftValue
    endIf
    return rightValue
EndFunction

; @module: RULES
String Function BoolToJson(Bool value) Global
    if value
        return "true"
    endIf

    return "false"
EndFunction

; @module: RULES
String Function ReplaceText(String sourceText, String needleText, String replacementText) Global
    Int sourceLength = StringUtil.GetLength(sourceText)
    Int needleLength = StringUtil.GetLength(needleText)
    if sourceLength <= 0 || needleLength <= 0 || sourceLength < needleLength
        return sourceText
    endIf

    String result = ""
    Int sourceIndex = 0
    Int lastStart = sourceLength - needleLength
    while sourceIndex < sourceLength
        Bool matched = False
        if sourceIndex <= lastStart
            matched = PDV_DevotionRules.StringMatchesAt(sourceText, needleText, sourceIndex)
        endIf

        if matched
            result = result + replacementText
            sourceIndex = sourceIndex + needleLength
        else
            result = result + StringUtil.GetNthChar(sourceText, sourceIndex)
            sourceIndex = sourceIndex + 1
        endIf
    endWhile

    return result
EndFunction

; @module: RULES
String Function AppendJsonItem(String accum, String item) Global
    if accum == ""
        return item
    endIf
    return accum + "," + item
EndFunction

; @module: RULES
Bool Function StringContainsToken(String haystackText, String needleText) Global
    Int haystackLength = StringUtil.GetLength(haystackText)
    Int needleLength = StringUtil.GetLength(needleText)
    if needleLength <= 0 || haystackLength < needleLength
        return False
    endIf

    Int startIndex = 0
    Int lastStart = haystackLength - needleLength
    while startIndex <= lastStart
        Int needleIndex = 0
        Bool matched = True
        while needleIndex < needleLength && matched
            if StringUtil.GetNthChar(haystackText, startIndex + needleIndex) != StringUtil.GetNthChar(needleText, needleIndex)
                matched = False
            endIf
            needleIndex = needleIndex + 1
        endWhile

        if matched
            return True
        endIf
        startIndex = startIndex + 1
    endWhile

    return False
EndFunction

; @module: RULES
String Function FormatTwoDecimals(Float value) Global
    Int scaledValue = (value * 100.0) as Int
    Int remainder = PDV_DevotionRules.AbsInt(scaledValue % 100)
    if remainder < 10
        return "" + (scaledValue / 100) + ".0" + remainder
    endIf

    return "" + (scaledValue / 100) + "." + remainder
EndFunction

; @module: RULES
Int Function BoolToInt(Bool value) Global
    if value
        return 1
    endIf
    return 0
EndFunction

; @module: RULES
String Function JsonSafeString(String rawText) Global
    if rawText == ""
        return ""
    endIf

    String safeText = ""
    Int i = 0
    Int count = StringUtil.GetLength(rawText)
    while i < count
        String currentChar = StringUtil.GetNthChar(rawText, i)
        Int currentOrd = StringUtil.AsOrd(currentChar)
        if currentChar == "\"" || currentChar == "\\"
            safeText = safeText + "'"
        elseIf currentOrd < 32
            safeText = safeText + " "
        else
            safeText = safeText + currentChar
        endIf
        i += 1
    endWhile

    return safeText
EndFunction

; @module: RULES
Float Function ClampValue(Float value, Float minValue, Float maxValue) Global
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf
    return value
EndFunction

; @module: RULES
Int Function ClampInt(Int value, Int minValue, Int maxValue) Global
    if value < minValue
        return minValue
    elseIf value > maxValue
        return maxValue
    endIf
    return value
EndFunction
