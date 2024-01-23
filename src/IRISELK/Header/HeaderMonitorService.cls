/// Monitor MessageHeaders
Class IRISELK.Header.HeaderMonitorService Extends Ens.BusinessService [ Language = objectscript ]
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
		do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..%ConfigName, "LastKey_" _ $NAMESPACE, 0)
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

		if namespace = $NAMESPACE // Skip current namespace (where the monitoring production runs), not needed for header monitoring
		{
			continue
		}

		set req = ##class(IRISELK.Header.HeaderMonitorRequest).%New()

        set lastkey = ..GetMessageHeadersInNamespace(req, namespace)

		if (req.HeaderData.Count() > 0)
		{
			do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

			$$$TRACE("Sending " _ req.HeaderData.Count() _ " MessageHeaders starting from " _ lastkey _ " in namespace " _ namespace)
		}
		else
		{
			$$$TRACE("Found no MessageHeaders starting from " _ lastkey _ " in namespace " _ namespace)
		}
	}
	
	return $$$OK
}

/// Get MessageHeaders in specified namespace
Method GetMessageHeadersInNamespace(req As IRISELK.Header.HeaderMonitorRequest, namespace As %String) As %String
{
    new $NAMESPACE
    set $NAMESPACE = namespace

    set currentlastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "LastKey_" _ namespace)
    set query = "SELECT ID,Banked,BusinessProcessId,CorrespondingMessageId,Description,ErrorStatus,Invocation,IsError, " _
                "MessageBodyClassName,MessageBodyId,Priority,Resent,ReturnQueueName,SessionId,SourceBusinessType,SourceConfigName, " _
                "Status,SuperSession,TargetBusinessType,TargetConfigName,TargetQueueName,TimeCreated,TimeProcessed,Type " _
                "FROM Ens.MessageHeader WHERE ID > ?"

    // create sql statement, set select mode to 2 for display mode for fields with a VALUELIST
    set tStatement = ##class(%SQL.Statement).%New()
    set tStatement.%SelectMode = 2
    do tStatement.%Prepare(query)
    #dim rset As %SQL.StatementResult = tStatement.%Execute(currentlastkey)

    while (rset.%Next())
	{
		// set lastkey based on ID of row
        set lastkey = rset.%Get("ID")
        do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..%ConfigName, "LastKey_" _ namespace, lastkey)
        set headerdata = ##class(IRISELK.Header.HeaderData).%New()
        set headerdata.ID = lastkey
        set headerdata.BusinessProcessId = rset.%Get("BusinessProcessId")
		set headerdata.CorrespondingMessageId = rset.%Get("CorrespondingMessageId")
        set headerdata.ErrorStatusDisplay = ##class(%SYSTEM.Status).GetErrorText(rset.%Get("ErrorStatus")) // get error text from errorstatus
		set headerdata.InvocationDisplay = rset.%Get("Invocation")
		set headerdata.IsError = rset.%Get("IsError")
		set headerdata.MessageBodyClassName = rset.%Get("MessageBodyClassName")
		set headerdata.MessageBodyId = rset.%Get("MessageBodyId")
		set headerdata.PriorityDisplay = rset.%Get("Priority")
		set headerdata.Resent = rset.%Get("Resent")
        set headerdata.ReturnQueueName = rset.%Get("ReturnQueueName")
        set headerdata.SessionId = rset.%Get("SessionId")
        set headerdata.SourceBusinessTypeDisplay = rset.%Get("SourceBusinessType")
        set headerdata.SourceConfigName = rset.%Get("SourceConfigName")
        set headerdata.StatusDisplay = rset.%Get("Status")
        set headerdata.SuperSession = rset.%Get("SuperSession")
        set headerdata.TargetBusinessTypeDisplay = rset.%Get("TargetBusinessType")
        set headerdata.TargetConfigName = rset.%Get("TargetConfigName")
        set headerdata.TargetQueueName = rset.%Get("TargetQueueName")
        set headerdata.TimeCreated = rset.%Get("TimeCreated")
        set headerdata.TimeProcessed = rset.%Get("TimeProcessed")
        set headerdata.TypeDisplay = rset.%Get("Type")
		set headerdata.Namespace = namespace
        set headerdata.TimeProcessedDiff = $SYSTEM.SQL.DATEDIFF("ms", headerdata.TimeCreated, headerdata.TimeProcessed)

		do req.HeaderData.Insert(headerdata)

		// limit size of single message
		if (rset.%ROWCOUNT >= 100)
		{
			quit
		}
    }

	return currentlastkey
}

}
