Class IRISELK.ErrorHandler.ErrorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Initialize the %Lastkey values
Method OnInit() As %Status
{
	#dim namespaces As %ListOfDataTypes = ##class(IRISELK.ProductionData.ProductionMonitorService).GetSupportedNamespaces()
	for i = 1:1:namespaces.Count()
	{
		new $NAMESPACE
		set $NAMESPACE = namespaces.GetAt(i)

		do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..%ConfigName, "LastKeyError_" _ $NAMESPACE, 0)
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..%ConfigName, "SuspendError_1", "0 -  - ")
        do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..%ConfigName, "SuspendError_2", "0 -  - ")
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
		if (req.Errorhandler.Count() > 0)
		{
			do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

			$$$TRACE("Sending " _ req.Errorhandler.Count() _ " EventLog records starting from " _ lastkey _ " in namespace " _ namespace)
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

    set currentlastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "LastKeyError_" _ namespace)

    set supresErrorValue1 = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "SuspendError_1")
    set suspendError1 = $PIECE(supresErrorValue1, "-", 1)
    set supresErrorValue2 = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "SuspendError_2")
    set suspendError2 = $PIECE(supresErrorValue2, "-", 1)
    set currentTime = $HOROLOG

    if (suspendError1){
        set suspendTime = $PIECE(supresErrorValue1, "-", 3)
        if ( (suspendTime < currentTime) || ( ($PIECE(suspendTime, ",", 2)) < ($PIECE(currentTime, ",", 2)) ) ) {
            do ##class(IRISELK.Util.SupressError).UnSuspendError(1)
            set suspendError1 = 0
        } else {set suspendText1 = $PIECE(supresErrorValue1, "-", 2)}
    }

    if (suspendError2){
        set suspendTime = $PIECE(supresErrorValue2, "-", 3)
        if ( (suspendTime < currentTime) || ( ($PIECE(suspendTime, ",", 2)) < ($PIECE(currentTime, ",", 2)) ) ) {
            do ##class(IRISELK.Util.SupressError).UnSuspendError(2)
            set suspendError2 = 0
        } else {set suspendText2 = $PIECE(supresErrorValue2, "-", 2)}
    }


    set query = "SELECT ID,ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Stack,Text,TimeLogged,TraceCat,Type "
               _"FROM Ens_Util.Log WHERE ID > ? AND (Type = 2 OR Type = 6) ORDER BY ID"
	set tStatement = ##class(%SQL.Statement).%New()
	do tStatement.%Prepare(query)
	#dim rset As %SQL.StatementResult = tStatement.%Execute(currentlastkey)

    set compairQuery = "SELECT ID,ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Stack,Text,TimeLogged,TraceCat,Type "
               _"FROM Ens_Util.Log WHERE ID > ? AND (Type = 2 OR Type = 6) ORDER BY ID"
	set compairTStatement = ##class(%SQL.Statement).%New()
	do compairTStatement.%Prepare(query)
	#dim compairRset As %SQL.StatementResult = compairTStatement.%Execute(compairQuery)

	while (rset.%Next())
    {   
        // set lastkey based on ID of row
        set lastkey = rset.%Get("ID")
        set suspendCounter = 0
        set compairText = $PIECE(rset.%Get("Text"), "-", 4)
        set source = $PIECE($PIECE(rset.%Get("Text"), "-", 2), " ", 3 )
        set prio = $PIECE($PIECE(rset.%Get("Text"), "-", 2), " ", 2 )  

        // Add a check for correct data type !!!!!!!!!!!
        // But make one specific for once that have to be set to prio 2 and prio 3
        // ( Filter is mostly meant for stuff from MessageHeaderHandler )
        if '(prio?1N) {
            set prio = 2
            if ( '(rset.%Get("SourceClass") = "Ens.Actor") && (rset.%Get("SourceMethod") = "MessageHeaderHandler") ){
                set prio = 3
            }
        }

        if '(source?1A){
            set source = "ITZOS"
        }
        #; if ( ('(source?1A) && '(source ="ITZOS")) || (rset.%Get("Text") [ "Er is een systeem fout opgetreden") ) {
        #;     if (rset.%Get("SourceClass") = "Ens.Actor"){
        #;         set source = "ITZOS"
        #;     } else {
        #;         set source = ..SourceFilter(rset.%Get("ID"), rset.%Get("SessionId"))
        #;     }
        #; }
        
        if (suspendError1){
            if (rset.%Get("Text") [ suspendText1){
                set prio = 4
                set source = "ITZOS"
            }
        } elseif (suspendError2){
            if (rset.%Get("Text") [ suspendText2){
                set prio = 4
                set source = "ITZOS"
            }
        }

        if ((source [ "ITZOS") && prio '= 4){
            while (compairRset.%Next()){
                if (compairRset.%Get("Text") [ compairText){
                    set suspendCounter = suspendCounter + 1
                }
            }

            set compairRset = compairTStatement.%Execute(compairQuery)

            if ((suspendCounter > 9) &&  (suspendCounter < 18)){
                
                set text = "The following error text has occured more then 10 times in errors. Subsequent errors with this text have been supressed, but will be send to elastic"

                set eventdata = ##class(IRISELK.ErrorHandler.Data.ErrorData).%New()

                // check and filter stack and text fields because they might contain sensitive data
                set eventdata.Text = text
                set eventdata.TimeLogged = $ZDATETIME($HOROLOG, 3, 1)
                set eventdata.Type = "Error"
                set eventdata.Namespace = namespace
                set eventdata.SourceCode = source
                set eventdata.Prio = 1

                do req.Errorhandler.Insert(eventdata)

            }
            if (suspendCounter > 9) {
                set prio = 4
            }
        } 
        
        // filter out user traces
        if ('(rset.%Get("TraceCat") = "user") )
        {

            set eventdata = ##class(IRISELK.ErrorHandler.Data.ErrorData).%New()

            // check and filter stack and text fields because they might contain sensitive data
            set eventdata.Stack = ##class(IRISELK.Util.Filter).ReplaceData(rset.%Get("Stack"))
            set eventdata.Text = ##class(IRISELK.Util.Filter).ReplaceData(rset.%Get("Text"))
            set eventdata.ID = lastkey
            set eventdata.ConfigName = rset.%Get("ConfigName")
            set eventdata.Job = rset.%Get("Job")
            set eventdata.MessageId = rset.%Get("MessageId")
            set eventdata.SessionId = rset.%Get("SessionId")
            set eventdata.SourceClass = rset.%Get("SourceClass")
            set eventdata.SourceMethod = rset.%Get("SourceMethod")
            set eventdata.TimeLogged = rset.%Get("TimeLogged")
            set eventdata.TraceCat = rset.%Get("TraceCat")
            set eventdata.Type = ##class(Ens.DataType.LogType).LogicalToDisplay(rset.%Get("Type"))
            set eventdata.Namespace = namespace
            set eventdata.SourceCode = source
            set eventdata.Prio = prio

            do req.Errorhandler.Insert(eventdata)

        }
        
        do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..%ConfigName, "LastKeyError_" _ namespace, lastkey)


        // limit size of single message
        if (rset.%ROWCOUNT > 50)
        {
            quit
        }
    }
    set currentlastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "LastKeyError_" _ namespace)

	return currentlastkey
}

Method SourceFilter(id As %Integer, sessionId As %Integer) As %String
{

    set source = "ITZOS"

    set query2 = "SELECT ID,ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Stack,Text,TimeLogged,TraceCat,Type "
                _"FROM Ens_Util.Log WHERE (ID = ?) AND (Type = 2 OR Type = 6)"
    set compairStatement = ##class(%SQL.Statement).%New()
    do compairStatement.%Prepare(query2) 
    #dim compairRset As %SQL.StatementResult = compairStatement.%Execute(id - 1)
    do compairRset.%Next()

    if (sessionId = compairRset.%Get("SessionId")){
        set compairSource = $PIECE($PIECE(compairRset.%Get("Text"), "-", 2), " ", 3 )
        if ( ('(compairSource?1A) && '(compairSource ="ITZOS")) || (compairRset.%Get("Text") [ "Er is een systeem fout opgetreden") ){

            do compairStatement.%Prepare(query2)
            set compairRset = compairStatement.%Execute(id - 2)
            do compairRset.%Next()
            
            if (sessionId = compairRset.%Get("SessionId")){
                set compairSource = $PIECE($PIECE(compairRset.%Get("Text"), "-", 2), " ", 3 )
                if ( compairSource?1A ){
                    set source = compairSource
                }
            } else {

                do compairStatement.%Prepare(query2)
                set compairRset = compairStatement.%Execute(id + 1)
                do compairRset.%Next()


                if (sessionId = compairRset.%Get("SessionId")) {
                    set compairSource = $PIECE($PIECE(compairRset.%Get("Text"), "-", 2), " ", 3 )
                    if ( ('(compairSource?1A) && '(compairSource ="ITZOS")) || (compairRset.%Get("Text") [ "Er is een systeem fout opgetreden") ){

                        do compairStatement.%Prepare(query2)
                        set compairRset = compairStatement.%Execute(id + 2)
                        do compairRset.%Next()

                        if (sessionId = compairRset.%Get("SessionId")){
                            set compairSource = $PIECE($PIECE(compairRset.%Get("Text"), "-", 2), " ", 3 )
                            if ( compairSource?1A ){
                                set source = compairSource
                            }
                        }
                    } else {
                        set source = compairSource
                    }
                }
            }
            
        } else {
            set source = compairSource
        }
    } else {

        do compairStatement.%Prepare(query2)
        set compairRset = compairStatement.%Execute(id + 1)
        do compairRset.%Next()

        if (sessionId = compairRset.%Get("SessionId")) {
            set compairSource = $PIECE($PIECE(compairRset.%Get("Text"), "-", 2), " ", 3 )
            if ( ('(compairSource?1A) && '(compairSource ="ITZOS")) || (compairRset.%Get("Text") [ "Er is een systeem fout opgetreden") ){

                do compairStatement.%Prepare(query2)
                set compairRset = compairStatement.%Execute(id + 2)
                do compairRset.%Next()

                if (sessionId = compairRset.%Get("SessionId")){
                    set compairSource = $PIECE($PIECE(compairRset.%Get("Text"), "-", 2), " ", 3 )
                    if ( compairSource?1A ){
                        set source = compairSource
                    }
                }
            } else {
                set source = compairSource
            }
        }
    }
    return source
}

}
