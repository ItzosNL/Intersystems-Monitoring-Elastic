Class IRISELK.Task.TaskData Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

/// Date the log entry is made
Property LogDate As %Date(%JSONFIELDNAME = "log_date");

/// Time the log entry is made
Property LogTime As %Time(%JSONFIELDNAME = "log_time");

/// Code That was run
Property ExecuteCode As %String(%JSONFIELDNAME = "execute_code", MAXLEN = 32000);

/// $h Value of when the task was last started<br>
/// 0 - Never started
Property LastStarted As %String(%JSONFIELDNAME = "last_started") [ InitialExpression = 0 ];

/// $h Value of when the task was last finished<br>
/// 0 - Never finished
Property LastFinished As %String(%JSONFIELDNAME = "last_finished") [ InitialExpression = 0 ];

/// Name of the task. Must be 16 characters or less, first character
/// must be a letter.
Property Name As %String(%JSONFIELDNAME = "task_name", MAXLEN = 32000);

/// Calculated by the system
Property Number As %Integer(%JSONFIELDNAME = "task_number") [ InitialExpression = 0, Internal ];

/// Namespace the task ran in
Property Namespace As %String(%JSONFIELDNAME = "Namespace", MAXLEN = 64) [ InitialExpression = "%SYS" ];

/// $lb(date,index) in %ER global on error
Property ER As %String(%JSONFIELDNAME = "ER", MAXLEN = 20);

/// Untrapped error from User task, or "Success"
Property Error As %String(%JSONFIELDNAME = "task_error", MAXLEN = 1024);

/// $J value of the job which ran the task
Property RunningJobNumber As %String(%JSONFIELDNAME = "running_job_number");

/// ID of Task
Property Task As %Integer(%JSONFIELDNAME = "task_id");

Property DisplayStarted As %String(%JSONFIELDNAME = "display_started");

Property DisplayFinished As %String(%JSONFIELDNAME = "display_finished");

Property DisplayStatus As %String(%JSONFIELDNAME = "display_status", MAXLEN = 1024);

Property DisplayErrorDate As %Date(%JSONFIELDNAME = "display_error_date");

Property DisplayErrorNumber As %String(%JSONFIELDNAME = "display_error_number");

Property DisplayLogDate As %String(%JSONFIELDNAME = "display_log_date", MAXLEN = 255);

Property Username As %String(%JSONFIELDNAME = "username");

Storage Default
{
<Data name="TaskDataState">
<Value name="1">
<Value>LogDate</Value>
</Value>
<Value name="2">
<Value>LogTime</Value>
</Value>
<Value name="3">
<Value>Status</Value>
</Value>
<Value name="4">
<Value>ExecuteCode</Value>
</Value>
<Value name="5">
<Value>LastStarted</Value>
</Value>
<Value name="6">
<Value>LastFinished</Value>
</Value>
<Value name="7">
<Value>Name</Value>
</Value>
<Value name="8">
<Value>Number</Value>
</Value>
<Value name="9">
<Value>NameSpace</Value>
</Value>
<Value name="10">
<Value>ER</Value>
</Value>
<Value name="11">
<Value>Error</Value>
</Value>
<Value name="12">
<Value>RunningJobNumber</Value>
</Value>
<Value name="13">
<Value>Task</Value>
</Value>
<Value name="14">
<Value>DisplayStarted</Value>
</Value>
<Value name="15">
<Value>DisplayFinished</Value>
</Value>
<Value name="16">
<Value>DisplayStatus</Value>
</Value>
<Value name="17">
<Value>DisplayErrorDate</Value>
</Value>
<Value name="18">
<Value>DisplayErrorNumber</Value>
</Value>
<Value name="19">
<Value>DisplayLogDate</Value>
</Value>
<Value name="20">
<Value>Username</Value>
</Value>
<Value name="21">
<Value>Namespace</Value>
</Value>
</Data>
<State>TaskDataState</State>
<StreamLocation>^IRISELK.Task.TaskDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
