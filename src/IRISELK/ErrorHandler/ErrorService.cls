/// The basic functionality of this class is to only send Errors and Alerts to the logstash.
/// Before sending the data it also adds new data (if not already included in de error) when sending the error, Prio and Source.
/// These 2 can be used to filter the errors in severity (prio) and to what place it needs to go (source) in later stages (ELK Watcher or a BO)
/// If the error has no prio or source it sets it.
/// The class also uses the functions from Utils.SupressError.cls to suspend incoming errors if set.
Class IRISELK.ErrorHandler.ErrorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ConfigName = "IRISELK.ErrorHandler.ErrorService";

/// Define the default source code for the errors
Parameter ADAPTER = "Ens.InboundAdapter";

/// %String value that represents the default source code. If left empty an empty string is used instead.
/// The value is used to identify errors that dont need to be send to the primary reciever of the errors.
/// It is automaticaly assigned to an error when one is not already found in the exception or error. 
/// More uses can be found in the IRISELK.Util.ErrorCodeFunctions class.
Property DefaultSource As %String;

/// Optional %String value to assign a Client source code. If left empty an empty string is used instead.
/// The value is used to identify errors that dont need to be send to the primary reciever of the errors.
/// It is assigend in IRISELK.Util.ErrorCodeFunctions to specific errors (see IRISELK.Util.ErrorCodeFunctions class for more info)
Property ClientName As %String;

/// Optional value that uses a Date or DataTime stamp in the format yyyy-mm-dd hh:mm:ss.
/// It can be used when first starting up the BS to set the ID of the EventLog where the code begins its search for logged Errors or Alerts.
/// When left empty it will use the highest ID from the EventLog from each namespace.
Property EventLogTimeLogged As %String;

Parameter SETTINGS = "DefaultSource:Basic,ClientName:Basic,EventLogTimeLogged:Basic";

/// Initialize the %Lastkey values
Method OnInit() As %Status
{
    set ^DefaultSource = ..DefaultSource
    set ^ClientName = ..ClientName
   
    if ((..DefaultSource = "") || (..ClientName = "")){
        $$$LOGERROR("Default source or client name property not filled. Make sure they are filled!!")
	}

	#dim namespaces As %ListOfDataTypes = ##class(IRISELK.ProductionData.ProductionMonitorService).GetSupportedNamespaces()
	for i = 1:1:namespaces.Count()
	{
		new $NAMESPACE
		set $NAMESPACE = namespaces.GetAt(i)

        // Initialize a Persistant value that holds the ID from a namespace's EventLog.
        // Either uses the highest posible ID or if ..EventLogTimeLogged is filled in the lowest ID from the given date.
        set sc = ..GetKeyValue(.keyValue)

        // If you want it to start from a specific ID use the following captioned code to set the LastKeyError value.
        // Add to the if-statement if you need the value to be changed for multiple namespaces.
        #; if $NAMESPACE = "<namespace>" {
        #;     do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..#ConfigName, "LastKeyError_" _ $NAMESPACE, <ID value>)
        #; }

        $$$TRACE("keyValue: " _ keyValue)
        
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..#ConfigName, "LastKeyError_" _ $NAMESPACE, keyValue)

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

    // Query Type 2 en 6 (Errors and Alerts) from the eventLog
    set query = "SELECT ID,ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Stack,Text,TimeLogged,Type "
               _"FROM Ens_Util.Log WHERE ID > ? AND (Type = 2 OR Type = 6) ORDER BY ID"
	set tStatement = ##class(%SQL.Statement).%New()
	do tStatement.%Prepare(query)
	#dim rset As %SQL.StatementResult = tStatement.%Execute(lastkey)

	while (rset.%Next())
    {
        // Set lastkey based on ID of row
        set lastkey = rset.%Get("ID")

        // filter out user traces
        set eventdata = ##class(IRISELK.ErrorHandler.Data.ErrorData).%New()

        // check and filter stack and text fields because they might contain sensitive data
        set eventdata.ID            = rset.%Get("ID")
        set eventdata.ConfigName    = rset.%Get("ConfigName")
        set eventdata.Job           = rset.%Get("Job")
        set eventdata.MessageId     = rset.%Get("MessageId")
        set eventdata.SessionId     = rset.%Get("SessionId")
        set eventdata.SourceClass   = rset.%Get("SourceClass")
        set eventdata.SourceMethod  = rset.%Get("SourceMethod")
        set eventdata.Stack         = rset.%Get("Stack")
        set eventdata.Text          = ##class(IRISELK.Util.Filter).ReplaceData(rset.%Get("Text"))
        set eventdata.TimeLogged    = rset.%Get("TimeLogged")
        set eventdata.Type          = rset.%Get("Type")
        set eventdata.Namespace     = namespace

        // Retrieve SourceCode and Prio from text
        set eventdata.SourceCode    = $PIECE($PIECE(eventdata.Text, " - ", 2), " ", 2)
        set eventdata.Prio          = $PIECE($PIECE(eventdata.Text, " - ", 2), " ", 1)

        $$$TRACE("eventdata: " _ eventdata.SourceCode)

        // If SourceCode is invalid, set to default
        if (eventdata.SourceCode '= $GET(^["MONITORING"]ClientName)) {
            set eventdata.SourceCode = $GET(^["MONITORING"]DefaultSource)
        }

        // Sets Prio to 2 (default) if invalid
        // Prio range is [1, 4]
        if '($ISVALIDNUM(eventdata.Prio) && ((eventdata.Prio >= 1) && (eventdata.Prio <= 4))) {
            set eventdata.Prio = 2

            if (rset.%Get("SourceMethod") = "MessageHeaderHandler"){
                set eventdata.Prio = 3

                if ( rset.%Get("Text")["SQLSTATE[22001]") {
                    set eventdata.Prio = 4
                }
            }
        }

        // Retrieve status text from text
        set compareText = $PIECE(eventdata.Text, "-", 4)

        // Check if the error needs to be suspended
        do ..SetPrioAndSourceIfSuspended(1, suspendError1, compareText, suspendText1, eventdata.SourceCode, eventdata.Prio)
        do ..SetPrioAndSourceIfSuspended(2, suspendError2, compareText, suspendText2, eventdata.SourceCode, eventdata.Prio)

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
        set source = $GET(^["MONITORING"]DefaultSource)
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

/// Method to return an ID from the EventLog of a namespace.
/// %ARG ByRef keyValue %Integer. This is the ID returned from a query on the EventLog DB table.
Method GetKeyValue(ByRef keyValue As %Integer) As %Status
{
    set sc = $$$OK
    set keyValue = 0

    try {
        if (..EventLogTimeLogged = ""){
            set ..EventLogTimeLogged = $ZDATE($PIECE($HOROLOG, " ", 1), 3)
        }

        set eventLogTimeLogged = ..EventLogTimeLogged

        &sql(SELECT MIN(ID) INTO :keyValue FROM Ens_Util.Log WHERE TimeLogged >= :eventLogTimeLogged )
        if (SQLCODE<0) {
            set keyValue = 0
            $$$LOGERROR("Fout tijdens het ophalen van eerste EvenLog ID van datum: " _ eventLogTimeLogged _ ". Namespace" _ $NAMESPACE _ ". SQL message: "_ %msg)
        }
        
        if (keyValue = "") {
            &sql(SELECT MAX(ID) INTO :keyValue FROM Ens_Util.Log )
            if (SQLCODE<0) {
                set keyValue = 0
                $$$LOGERROR("Fout tijdens het ophalen van meest resente EvenLog ID. Namespace: " _ $NAMESPACE _ ". SQL message: "_ %msg)
            }
            set:(keyValue = "") keyValue = 0
        } 
    } catch ex {
        set sc = ex.AsStatus()
    }

    return sc
}

}
