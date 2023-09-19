/// Incrementally gather and send Task History
Class IRISELK.Task.TaskMonitorService Extends Ens.BusinessService [ Language = objectscript ]
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
    set req = ##class(IRISELK.Task.TaskMonitorRequest).%New()

	// set lastkey parameter to keep track of already processed rows
	set lastkey = ##class(EnsLib.SQL.InboundAdapter).GetPersistentValue(..%ConfigName, "%LastKey")
    set newlastkey = ..GetTaskHistory(req, lastkey)

	if (req.TaskData.Count() > 0)
    {
        do ##class(EnsLib.SQL.InboundAdapter).SetPersistentValue(..%ConfigName, "%LastKey", newlastkey)

 		do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

		$$$TRACE("Sending " _ req.TaskData.Count() _ " Task History Records starting from " _ lastkey)
	}
    else
    {
		$$$TRACE("Found no Task History Records starting from " _ lastkey)
	}

	return $$$OK
}

/// Get new recoirds in Task History
Method GetTaskHistory(req As IRISELK.Task.TaskMonitorRequest, lastkey As %String) As %String
{
    NEW $NAMESPACE
    set $NAMESPACE = "%SYS"
    set query = "SELECT ID, DisplayErrorDate, DisplayErrorNumber, DisplayFinished, DisplayLogDate, DisplayStarted, " _
                "DisplayStatus, ER, Error, ExecuteCode, LastFinished, LastStarted, LogDate, LogTime, Name, NameSpace, " _
                "Number, RunningJobNumber, Status, Task, Username FROM %SYS_Task.History WHERE ID > ?"
    set tStatement = ##class(%SQL.Statement).%New()
    do tStatement.%Prepare(query)
    #dim rset As %SQL.StatementResult = tStatement.%Execute(lastkey)

    while (rset.%Next())
    {
        // set lastkey
        set lastkey = rset.%Get("ID")
        set taskdata = ##class(IRISELK.Task.TaskData).%New()
        set taskdata.LogDate = rset.%Get("LogDate")
        set taskdata.LogTime = rset.%Get("LogTime")
        set taskdata.ExecuteCode = rset.%Get("ExecuteCode")
        set taskdata.LastStarted = rset.%Get("LastStarted")
        set taskdata.LastFinished = rset.%Get("LastFinished")
        set taskdata.Name = rset.%Get("Name")
        set taskdata.Number = rset.%Get("Number")
        set taskdata.Namespace = rset.%Get("Namespace")
        set taskdata.ER = rset.%Get("ER")
        set taskdata.Error = rset.%Get("Error")
        set taskdata.RunningJobNumber = rset.%Get("RunningJobNumber")
        set taskdata.Task = rset.%Get("ID")
        set taskdata.DisplayStarted = rset.%Get("DisplayStarted")
        set taskdata.DisplayFinished = rset.%Get("DisplayFinished")
        set taskdata.DisplayStatus = rset.%Get("DisplayStatus")
        set taskdata.DisplayErrorDate = rset.%Get("DisplayErrorDate")
        set taskdata.DisplayErrorNumber = rset.%Get("DisplayErrorNumber")
        set taskdata.DisplayLogDate = rset.%Get("DisplayLogDate")
        set taskdata.Username = rset.%Get("Username")

        do req.TaskData.Insert(taskdata)

        // limit size of single message
        if (rset.%ROWCOUNT > 50)
        {
             quit
        }
    }

    return lastkey
}

}
