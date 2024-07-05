/// The basic functionality of this class is to only send Errors and Alerts to the logstash.
/// Before sending the data it also adds new data (if not already included in de error) when sending the error, Prio and Source.
/// These 2 can be used to filter the errors in severity (prio) and to what place it needs to go (source) in later stages (ELK Watcher or a BO)
/// If the error has no prio or source it sets it.
/// The class also uses the functions from Utils.SupressError.cls to suspend incoming errors if set.
Class IRISELK.ErrorHandler.ErrorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ConfigName = "IRISELK.ErrorHandler.ErrorService";

Property DefaultSource As %String;

/// Define the default source code for the errors
Parameter ADAPTER = "Ens.InboundAdapter";

Parameter SETTINGS = "DefaultSource:Basic";

/// Initialize the %Lastkey values
Method OnInit() As %Status
{
   

    set ^DefaultSource = ..DefaultSource

	#dim namespaces As %ListOfDataTypes = ##class(IRISELK.ProductionData.ProductionMonitorService).GetSupportedNamespaces()
	for i = 1:1:namespaces.Count()
	{
		new $NAMESPACE
		set $NAMESPACE = namespaces.GetAt(i)

        // Persistant value that holds the last ID from a logged error or alert from a namespace
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..#ConfigName, "LastKeyError_" _ $NAMESPACE, 0)

        // Persistant value that holds an error text that needs to be supressed (prio = 4)
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..#ConfigName, "SuspendError_1", "0 -  - ")
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..#ConfigName, "SuspendError_2", "0 -  - ")

        // Persistant value for the count of a suppres error
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..#ConfigName, "SuspendCounter_1", 0)
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..#ConfigName, "SuspendCounter_2", 0)
	}
	return $$$OK
}

/// Called every time the CallInterval expires
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	#dim namespaces As %ListOfDataTypes = ##class(IRISELK.ProductionData.ProductionMonitorService).GetSupportedNamespaces()
	for i = 1:1:namespaces.Count()
	{   
		set namespace = namespaces.GetAt(i)
		set req = ##class(IRISELK.ErrorHandler.Data.ErrorRequest).%New()
        set lastkey = ..GetEventLogInNameSpace(req, namespace)

		// Send data per namespace!
		if (req.ErrorData.Count() > 0)
		{
			do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

			$$$TRACE("Sending " _ req.ErrorData.Count() _ " EventLog records till " _ lastkey _ " in namespace " _ namespace)
		}
		else
		{
			$$$TRACE("Found no EventLog records starting from " _ lastkey _ " in namespace " _ namespace)
		}
	}
	
	return $$$OK
}

/// Get EventLog in specified namespace
Method GetEventLogInNameSpace(req As IRISELK.ErrorHandler.Data.ErrorRequest, namespace As %String) As %String
{
    new $NAMESPACE
    set $NAMESPACE = namespace

    set lastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "LastKeyError_" _ namespace)

    // Check if a suspended error needs to be unsupressed based on the time that was set for it
    set suspendError1 = ..IsErrorSuspensionActive(1, .suspendText1)

    // Check if a suspended error needs to be unsupressed based on the time that was set for it 
    set suspendError2 = ..IsErrorSuspensionActive(2, .suspendText2)

    // Query Type 2 en 6 (Errors en Alerts) from the eventLog
    set query = "SELECT ID,ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Stack,Text,TimeLogged,Type "
               _"FROM Ens_Util.Log WHERE ID > ? AND (Type = 2 OR Type = 6) ORDER BY ID"
	set tStatement = ##class(%SQL.Statement).%New()
	do tStatement.%Prepare(query)
	#dim rset As %SQL.StatementResult = tStatement.%Execute(lastkey)

	while (rset.%Next())
    {   
        // Set lastkey based on ID of row
        set lastkey = rset.%Get("ID")
        set errorLogText = rset.%Get("Text")
        set compareText = $PIECE(errorLogText, "-", 4)
        set prioAndSource = $PIECE(errorLogText, "-", 2)
        set prio = $PIECE(prioAndSource, " ", 2 )  
        set source = $PIECE(prioAndSource, " ", 3 )
        set maskedErrorLogText = ##class(IRISELK.Util.Filter).ReplaceData(errorLogText)

        // Check if there is a prio in the logged error, if not set it.
        if '(prio?1N) {
            set prio = 2

            if ( '(rset.%Get("SourceClass") = "Ens.Actor") && (rset.%Get("SourceMethod") = "MessageHeaderHandler") ){
                set prio = 3
            }
        }

        // If there is no source in the logged error set it to the defaultSource
        if '(source?1A){
            set source = ..DefaultSource
        }
    
        // Check if the error needs to be suspended
        do ..SetPrioAndSourceIfSuspended(1, suspendError1, compareText, suspendText1, .source, .prio)
        do ..SetPrioAndSourceIfSuspended(2, suspendError2, compareText, suspendText2, .source, .prio)
        
        // filter out user traces
        set eventdata = ##class(IRISELK.ErrorHandler.Data.ErrorData).%New()

        // check and filter stack and text fields because they might contain sensitive data
        set eventdata.Stack = ##class(IRISELK.Util.Filter).ReplaceData(rset.%Get("Stack"))
        set eventdata.Text = ##class(IRISELK.Util.Filter).ReplaceData(maskedErrorLogText)
        set eventdata.ID = lastkey
        set eventdata.ConfigName = rset.%Get("ConfigName")
        set eventdata.Job = rset.%Get("Job")
        set eventdata.MessageId = rset.%Get("MessageId")
        set eventdata.SessionId = rset.%Get("SessionId")
        set eventdata.SourceClass = rset.%Get("SourceClass")
        set eventdata.SourceMethod = rset.%Get("SourceMethod")
        set eventdata.TimeLogged = rset.%Get("TimeLogged")
        set eventdata.Type = ##class(Ens.DataType.LogType).LogicalToDisplay(rset.%Get("Type"))
        set eventdata.Namespace = namespace
        set eventdata.SourceCode = source
        set eventdata.Prio = prio

        do req.ErrorData.Insert(eventdata)
        
        do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..#ConfigName, "LastKeyError_" _ namespace, lastkey)

        // limit size of single message
        if (rset.%ROWCOUNT > 50)
        {
            quit
        }
    }

	return lastkey
}

/// If an error is suspended set the prio to 4 and source to the default
/// If the error is suspended but has been seen for the 15th time it will set the prio to 1 for that error
/// @suspendErrorNum is the persistnatvalue number that has the suspended error
/// @suspendError is a boolean that shows if there is an error that needs to be supressed
/// @compareText is the text that from the logged error that needs to be checked for a supression
/// @suspendText is the text that needs to be searched for in the logged error (text from the persistant value)
/// @source is the output for the source for the error
/// @prio is the output for the prio for the error
Method SetPrioAndSourceIfSuspended(suspendErrorNum As %Integer, suspendError As %Boolean, compareText As %String, suspendText As %String, ByRef source As %String, ByRef prio As %Integer)
{

    if (suspendError && (compareText [ suspendText))
    {
        set source = ..DefaultSource
        set suspendedCounter = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "SuspendCounter_" _ suspendErrorNum) + 1

        do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..#ConfigName, "SuspendCounter_" _ suspendErrorNum, suspendedCounter)

        // Remove if you dont want an occasional sending of a suspended error
        if (suspendedCounter # 15) = 0 {
            set prio = 1
        } else { set prio = 4 }
    }
}

/// Check if the suspension of an error is active, and if so if it needs to be suspended or not based on the time
/// Returns a boolean value if the error suspension is active
/// @suspendErrorNum is the persistnatvalue number that has the suspended error
/// @suspendText is the output for the text that needs to be searched for in the logged error (text from the persistant value)
Method IsErrorSuspensionActive(suspendErrorNum As %Integer, ByRef SuspendedErrorText As %String) As %Boolean
{
    set SuspendedErrorText = ""
   
    set SuspendedErrorValue = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..#ConfigName, "SuspendError_" _ suspendErrorNum)
    set suspendedErrorBoolean = $PIECE(SuspendedErrorValue, "-", 1)

    if '(suspendedErrorBoolean) { return 0 }

    set suspendTime = $PIECE(SuspendedErrorValue, " - ", 3)

    if $ZDATETIME(suspendTime, -2) < $ZDATETIME($HOROLOG, -2)
    {
        do ##class(IRISELK.Util.SupressError).UnSuspendError(suspendErrorNum)
        return 0
    } 

    set SuspendedErrorText = $PIECE(SuspendedErrorValue, "-", 2)
    return 1
}

}
