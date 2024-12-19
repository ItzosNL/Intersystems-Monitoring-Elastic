Include (Ensemble, %occErrors)

/// Class to log exceptions with proper formatting for filtering
Class IRISELK.Util.ErrorCodeFunctions
{

// Define a default source code

/// This method is used to log an exception.
/// If a request for repeating the job needs to be added to the loging of an error
/// add this to the retryRequest argument and add the propery name if it is not equal to 'MustRetry'
/// First example is for use on it's own, the second in a try-catch block.
/// <EXAMPLE>
/// 
///     if (1 '= 1){
///         set exception = ..generalException("Fout tijdens ophalen van medewerker uit AFAS")
///         do ..LogError(exception, $CLASSNAME())
///     }
/// 
/// =============
/// 
/// try {
/// 
///     ...
///     
///     if (1 '= 1){    
///         do ..generalException("Fout tijdens ophalen van medewerker uit AFAS")
///     }
/// 
/// } catch exception {
///     set resultRequest = ##class(responseForm).%New()
///     
///     do ..LogError(exception, $CLASSNAME(), resultRequest)
/// 
/// }
/// 
/// </EXAMPLE>
ClassMethod LogError(exception As %Exception.AbstractException, koppelingName As %String, ByRef retryRequest As Ens.Request = "", mustRetryPropertyName = "MustRetry") As %Status
{
   

    set defaultSource = ..GetDefaultSource()

    if exception.%IsA("%Exception.SystemException") {
        
        set text = "Er is een systeem fout opgetreden"
        set exc = ##Class(%Exception.SystemException).%New(koppelingName _ " -", 2 _ " " _ defaultSource _ " -",, text _ " - " _ exception.Name _ " #" _ exception.Code _ ": " _ exception.Data)
        //                                                             prio code ^   || Change if prio for system exceptions need different standard prio code || 

        $$$LOGERROR(exc.DisplayString())
        if (retryRequest '= "") {
            set $PROPERTY(retryRequest, mustRetryPropertyName) = 0
        }    
    } 
    elseif exception.%IsA("%Exception.SQL") {
        $$$LOGERROR(koppelingName _ " -" _ exception.DisplayString())
        if (retryRequest '= "") {
            set $PROPERTY(retryRequest, mustRetryPropertyName) = 1
        }
    }
    elseif exception.%IsA("%Exception.StatusException") {
        $$$LOGERROR(koppelingName _ " - " _ exception.Name _ exception.DisplayString())
        if (retryRequest '= "") {
            set $PROPERTY(retryRequest, mustRetryPropertyName) = 0
        }
    }
    elseif exception.%IsA("%Exception.General") {
        $$$LOGERROR(koppelingName _ " -" _ exception.DisplayString())
        if (retryRequest '= "") {
            set $PROPERTY(retryRequest, mustRetryPropertyName) = 1
        }
    }
    else 
    { 
        $$$LOGERROR(koppelingName _ " - 1 - Unnone error " _ exception.Code _ ": " _ exception.Data)
        if (retryRequest '= ""){
            set $PROPERTY(retryRequest, mustRetryPropertyName) = 0
        }
    }

    return $$$OK
}

/// Return a status exception in a standard format.
/// Use when throwing an error with a technical description based of a %status.
/// NOTE: Adding a prio code is not necessary when it needs to be a prio 3.
/// <EXAMPLE>
///  set sc = ..SendRequestSync()
///  if ('sc){
///     throw ..statusException(sc, "Functional description", 2)
///  }
/// </EXAMPLE>
ClassMethod statusException(sc As %Status, functCode As %String, prio As %Integer = 3) As %Exception.StatusException
{
    #dim statEx as %Exception.AbstractException = ##class(%Exception.StatusException).CreateFromStatus(sc)

    if statEx.%IsA("%Exception.SystemException")
    {
        return statEx
    }

    set source = ..GetDefaultSource()
    set exData = statEx.DisplayString()

    // If there isnt a HTTP status code 403 or 5xx, then assign it to defaultSource
    if (..SourceNeedsToBeClientName(exData) )
    {
        set source = ..GetClientName()
    }

    if (statEx.Code = 5035) // GeneralException
    {
        set data = $PIECE(exData, "-", 2, *)
        set error = $$$ERROR($$$GeneralError, data)
        set statEx = ##class(%Exception.StatusException).CreateFromStatus(error)
        
    }
    elseif ((statEx.Code = 6248) && (exData["SQLSTATE[22001]"))
    {   
        set stringData = $PIECE(exData, "'", 2)
        set data = "SQL error string data to long for " _ stringData
        set error = $$$ERROR($$$GeneralError, data)
        set statEx = ##class(%Exception.StatusException).CreateFromStatus(error)

    } 

    set statEx.Name = prio _ " " _ source _ " - " _ functCode _ " - "

    return statEx
}

/// Return a general exception in a standard format.
/// Use when throwing an error without a technical description.
/// NOTE: Adding a prio code is not necessary when it needs to be a prio 3.
/// <EXAMPLE>
/// if ( 1 '= 1 ){
///     throw ..generalException("Functional description", 2)
/// }
/// </EXAMPLE>
ClassMethod generalException(functCode As %String, prio As %Integer = 3) As %Exception.General
{

    set source = ..GetClientName()

    #; // If there isnt a HTTP status code 403 or 5xx, then assign it to defaultSource
    set dataHasHTTP403Or5xx = ..ExceptionDataHasHTTP403Or5xx(functCode, .matchFound)

    if ( ('(dataHasHTTP403Or5xx) && (matchFound))){
        set source = ..GetDefaultSource()
    }

    set data = functCode
    set prioCode = prio _ " " _ source _ " -"

    return ##class(%Exception.General).%New(, prioCode, , data)
}

/// Return a SQL exception in a standard format.
/// Use when throwing a SQL error.
/// NOTE: Adding a prio code is not necessary when it needs to be a prio 3.
/// <EXAMPLE>
/// 
///  Dynamic SQL:
///  set sql = ##class(%SQL.Statement).%New()
///  set query = "SELECT * FROM ErrorCode.Reden"
///  set qstate = sql.%Prepare(query)
///  set rset = sql.%Execute()
///  if (rset.%SQLCODE < 0){
///     if (rset.%SQLCODE = -400){
///         throw ..statusException(qstate, "Functional description", 2)
///     }
///     throw ..sqlException(rset.%SQLCODE, rset.%message, "Functional description", 2)
///   }
/// 
/// =================
///  Embedded SQL:
///  &sql(SELECT * FROM ErrorCode.Reden) 
///  if (SQLCODE < 0){
///     if (SQLCODE = -400){
///         throw ..statusException(qstate, functText)
///     }
///     throw ..sqlException(SQLCODE, %msg, functText)
///  }
/// 
/// </EXAMPLE>
ClassMethod sqlException(SQLCode As %Integer, message As %String, functCode As %String, prio As %Integer = 3) As %Exception.SQL
{
   
    set defaultSource = ..GetDefaultSource()

    set data = functCode _ " - SQL message: " _ SQLCode _ " " _ message
    set prio = prio _ defaultSource _ " -"

    return ##class(%Exception.SQL).%New(, prio, , data)
}

/// Function that groups other functions to determin if the source needs to be the ClientName.
ClassMethod SourceNeedsToBeClientName(data As %String) As %Boolean
{
    // For now only this function.
    // Add more functions to filter if the source needs to be the ClientName.
    return ..HTTPStatusIs403Or5xx(data)
}

/// Does this exception have an HTTP 403 or 5xx error?
/// If it does and it matches a code, check if there is an HTTP code
/// Return true (1) if the code maches 403 or a 5xx status code else return false (0)
ClassMethod HTTPStatusIs403Or5xx(data As %String) As %Boolean
{
    // Check if there is an intersystems error code in the exception
    set matchInterCode = $LOCATE(data, "#\d+:")

    if (matchInterCode '= 0)
    {   
        // Start checking what kind of code it is and return a boolean based on the code
        set interSysCode = $EXTRACT(data, (matchInterCode + 1), (matchInterCode + 4))

        if interSysCode = $$$CSPTimeout
        {
            return 1
        }

        if ( (interSysCode = $$$SOAPUnexpectedStatus) || (interSysCode = $$$GCMHTTPStatus) || (interSysCode = $$$SOAPFaultReceived))
        {
            set matchHTTPDot = $LOCATE(data, "\d{3}\.")
            set matchHTTP = $LOCATE(data, "\s\d{3}:")

            if (matchHTTPDot '= 0)
            {
                set HTTPCode = $EXTRACT(data, (matchHTTPDot), (matchHTTPDot + 2))
            }
            elseif (matchHTTP '= 0)
            {
                set HTTPCode = $EXTRACT(data, (matchHTTP + 1), (matchHTTP + 3))
            }
            else
            {
                return 0
            }
                                    // checks for 5xx status code
            return ( (HTTPCode = 403 ) || (HTTPCode ? 1"5"2N) )
        }
    }

    return ..ExceptionDataHasHTTP403Or5xx(data)
}

/// Is there an HTTP code 403 or 5xx anywhere in the exception data?
/// Check if there is a HTTP status code anywhere in the exception
/// Return true (1) if the code maches 403 or a 5xx status code else return false (0)
ClassMethod ExceptionDataHasHTTP403Or5xx(data As %String, ByRef matchFound As %Boolean) As %Boolean
{
    set matchFound = 0
    set HTTPCode = 0
    set matchHTTPCode = $LOCATE(data, "\d{3}")

    while matchHTTPCode '= 0
    {
        set precedingChar = $EXTRACT(data, matchHTTPCode - 1)

        // Is this a 3 digit number and not an Intersystems error code which would be preceded by a '#'?
        if (precedingChar '? 1N) && (precedingChar '? 1"#" ) && ($EXTRACT(data, matchHTTPCode + 3) '? 1N)
        {
            set HTTPCode = $EXTRACT(data, (matchHTTPCode), (matchHTTPCode+2))
            set matchFound = 1
                                      // checks for 5xx status code 
            return ( (HTTPCode = 403 ) || (HTTPCode ? 1"5"2N) )
        }

        // Find next 3 digit number
        set matchHTTPCode = $LOCATE(data, "\d{3}", matchHTTPCode + 3)
    }

    return 0
}

ClassMethod GetDefaultSource() As %String
{
    return ^["MONITORING"]DefaultSource
}

ClassMethod GetClientName() As %String
{

    return ^["MONITORING"]ClientName
}

}
