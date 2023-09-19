/// Monitor Event logs
Class IRISELK.EventLog.EventLogService Extends Ens.BusinessService [ Language = objectscript ]
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
		set req = ##class(IRISELK.EventLog.EventLogRequest).%New()
        set lastkey = ..GetEventLogInNameSpace(req, namespace)

		// Send data per namespace!
		if (req.EventLogData.Count() > 0)
		{
			do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

			$$$TRACE("Sending " _ req.EventLogData.Count() _ " EventLog records starting from " _ lastkey _ " in namespace " _ namespace)
		}
		else
		{
			$$$TRACE("Found no EventLog records starting from " _ lastkey _ " in namespace " _ namespace)
		}
	}
	
	return $$$OK
}

/// Get EventLog in specified namespace
Method GetEventLogInNameSpace(req As IRISELK.EventLog.EventLogRequest, namespace As %String) As %String
{
    new $NAMESPACE
    set $NAMESPACE = namespace

    set currentlastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "LastKey_" _ namespace)
    set query = "SELECT ID,ConfigName,Job,MessageId,SessionId,SourceClass,SourceMethod,Stack,Text,TimeLogged,TraceCat,Type FROM Ens_Util.Log WHERE ID > ?"
	set tStatement = ##class(%SQL.Statement).%New()
	do tStatement.%Prepare(query)
	#dim rset As %SQL.StatementResult = tStatement.%Execute(currentlastkey)

	while (rset.%Next())
    {
         // set lastkey based on ID of row
        set lastkey = rset.%Get("ID")

        do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..%ConfigName, "LastKey_" _ namespace, lastkey)

        // filter out user traces
        if '(rset.%Get("TraceCat") = "user")
		{
            set eventdata = ##class(IRISELK.EventLog.EventLogData).%New()

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

			do req.EventLogData.Insert(eventdata)

			// limit size of single message
			if (rset.%ROWCOUNT > 50)
			{
				quit
			}
        }
    }

	return currentlastkey
}

}
