/// Class to supress errors that have been logged.
/// The class is used in the Errorservice BS to set the prio to a 4 to 'supress' the error.
Class IRISELK.Util.SupressError
{

Parameter ConfigName = "IRISELK.ErrorHandler.ErrorService";

/// Suspend error containing the specified errorText for the specified time
/// @index is the persistant value taht needs to be changed
/// @errorText is the error text that needs to be looked at in the logged errors to suspend them
/// @timeExpression is the amount of time to suspend the error. Can be expressed in minutes, hours or days, e.g. "30m" for 30 minutes
ClassMethod SuspendError(index As %Integer, errorText As %String, timeExpression As %String)
{
    set date = +$HOROLOG
    set time = $PIECE($HOROLOG, ",", 2)
    set timeCodeLocation = $LOCATE(timeExpression, "[mhd]")

    if (timeCodeLocation <=  0)
    {
        write !, "No time code found"
        return
    }

    set duration = $EXTRACT(timeExpression, 0, timeCodeLocation - 1)
    set timeCode = $EXTRACT(timeExpression, timeCodeLocation)

    if (timeCode = "m")
    {
        set time = time + (duration * 60)
    }
    elseif (timeCode = "h")
    {
        set time = time + (duration * 3600)
    }
    elseif (timeCode = "d")
    {
        set date = date + duration
    }

    while (time > 86399)
    {
        set time = time - 86400
        set date = date + 1
    }

    set endDateTime = date _ "," _ time

    write !, "Persistant value " _ index," filled. Suspending errors containing '" _ errorText _ "' until " _ $ZDATETIME(endDateTime, 3, 1)

    do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..#ConfigName, "SuspendError_" _ index, "1 - " _  errorText _ " - " _ endDateTime)
}

/// Un-suspend an error and delete the count for it
/// @index is the persistant value to be unsuspend
ClassMethod UnSuspendError(index As %Integer)
{
    write !, index,": Unsuspending error"

    do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..#ConfigName, "SuspendError_" _ index, 0)
    do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..#ConfigName, "SuspendCounter_" _ index, 0)
}

/// Display suspended errors
ClassMethod DisplaySuspendedErrors()
{
    set supresErrorValue1 = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "SuspendError_1")
    set supresErrorValue2 = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "SuspendError_2")
    set text1 = ##class(IRISELK.Util.SupressError).StringSupresErrorText(supresErrorValue1)
    set text2 = ##class(IRISELK.Util.SupressError).StringSupresErrorText(supresErrorValue2)

    set suspendCounter1 = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "SuspendCounter_1")
    set suspendcounter2 = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "SuspendCounter_2")
    set counterText1 = ""
    set counterText2 = ""
    if suspendCounter1 '= 0 { set counterText1 =  "  Counter at: " _ suspendCounter1 }
    if suspendcounter2 '= 0 { set counterText2 =  "  Counter at: " _ suspendcounter2 }

    w !, "nr.1: " _ text1 _ counterText1
    w !, "nr.2: " _ text2 _ counterText2
}

/// Return a nicely formated string to be printed when displaying the content of a suspended error
/// @value is the String that is in the persistant value
ClassMethod StringSupresErrorText(value As %String) As %String
{
    if value = 0 { return "" }

    set errorText = $PIECE(value, "-", 2)
    set timeH = $PIECE(value, " - ", 3)
    set time = $ZDATETIME(timeH, 3, 1)
    set text = errorText _ " till: " _ time

    return text
}

}
