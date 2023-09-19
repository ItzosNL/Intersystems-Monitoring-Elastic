/// Monitor Audit database for login information
Class IRISELK.Audit.AuditMonitorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Initialize the %Lastkey value
Method OnInit() As %Status
{
	do ##class(EnsLib.SQL.InboundAdapter).InitializePersistentValue(..%ConfigName, "%LastKey", 0)
	return $$$OK
}

/// Called every time the CallInterval expires
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	set req = ##class(IRISELK.Audit.AuditMonitorRequest).%New()
	
	// set lastkey parameter to keep track of already processed rows
	set lastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "%LastKey")

    set newlastkey = ..GetAuditLogs(req, lastkey)

	if (req.AuditData.Count() > 0)
	{
		/// Update lastkey
		do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..%ConfigName, "%LastKey", newlastkey)
		do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

		$$$TRACE("Sending " _ req.AuditData.Count() _ " Audit Records starting from " _ lastkey)
	}
    else
    {
		$$$TRACE("Found no Audit Records starting from " _ lastkey)
	}

	return $$$OK
}

/// Get Audit Logs in %SYS namespace
Method GetAuditLogs(req As IRISELK.Audit.AuditMonitorRequest, lastkey As %String) As %String
{
    NEW $NAMESPACE
    set $NAMESPACE = "%SYS"
    set query = "SELECT ID, AuditIndex, Authentication, CSPSessionID, ClientExecutableName, ClientIPAddress, Description," _
                "Event, EventData, EventSource, EventType, GroupName, JobId, JobNumber, Namespace, OSUsername, Pid, Roles," _
                "RoutineSpec, Status, SystemID, UTCTimeStamp, UserInfo, Username FROM %SYS.Audit WHERE AuditIndex > ?"
	set tStatement = ##class(%SQL.Statement).%New()
	do tStatement.%Prepare(query)

	#dim rset As %SQL.StatementResult = tStatement.%Execute(lastkey)

    while (rset.%Next()) {
        set lastkey = rset.%Get("AuditIndex")	// set lastkey based on audit index

        set auditdata = ##class(IRISELK.Audit.AuditMonitorData).%New()
        set auditdata.ID = rset.%Get("ID")
        set auditdata.AuditIndex = lastkey
        set auditdata.Authentication = rset.%Get("Authentication")
        set auditdata.CSPSessionID = rset.%Get("CSPSessionID")
        set auditdata.ClientExecutableName = rset.%Get("ClientExecutableName")
        set auditdata.ClientIPAddress = rset.%Get("ClientIPAddress")
        set auditdata.Description = rset.%Get("Description")
        set auditdata.Event = rset.%Get("Event")
        set auditdata.EventData = rset.%Get("EventData")
        set auditdata.EventSource = rset.%Get("EventSource")
        set auditdata.EventType = rset.%Get("EventType")
        set auditdata.GroupName = rset.%Get("GroupName")
        set auditdata.JobId = rset.%Get("JobId")
        set auditdata.JobNumber = rset.%Get("JobNumber")
        set auditdata.Namespace = rset.%Get("Namespace")
        set auditdata.OSUsername = rset.%Get("OSUsername")
        set auditdata.Pid = rset.%Get("Pid")
        set auditdata.Roles = rset.%Get("Roles")
        set auditdata.RoutineSpec = rset.%Get("RoutineSpec")
        set auditdata.Status = rset.%Get("Status")
        set auditdata.SystemID = rset.%Get("SystemID")
        set auditdata.UTCTimeStamp = rset.%Get("UTCTimeStamp")
        set auditdata.UserInfo = rset.%Get("UserInfo")
        set auditdata.Username = rset.%Get("Username")

        do req.AuditData.Insert(auditdata)

        // limit size of single message
		if (rset.%ROWCOUNT >= 100) {
			quit
		}
	}

	return lastkey
}

}
