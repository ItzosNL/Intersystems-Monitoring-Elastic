Class IRISELK.Audit.AuditMonitorData Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

Property ID As %String(MAXLEN = 215) [ Required ];

Property AuditIndex As %BigInt [ Required ];

Property Authentication As %String;

Property CSPSessionID As %String;

Property ClientExecutableName As %String(MAXLEN = 128);

Property ClientIPAddress As %String(MAXLEN = 128);

Property Description As %String(MAXLEN = 128);

Property Event As %String(MAXLEN = 128);

Property EventData As %String(MAXLEN = 5000);

Property EventSource As %String(MAXLEN = 128);

Property EventType As %String(MAXLEN = 128);

Property GroupName As %String(MAXLEN = 128);

Property JobId As %String;

Property JobNumber As %Integer;

Property Namespace As %String(MAXLEN = 64);

Property OSUsername As %String;

Property Pid As %String;

Property Roles As %String(MAXLEN = 512);

Property RoutineSpec As %String(MAXLEN = 128);

Property Status As %Status;

Property SystemID As %String [ Required ];

Property UTCTimeStamp As %TimeStamp [ Required ];

Property UserInfo As %String(MAXLEN = 64);

Property Username As %String;

Storage Default
{
<Data name="AuditMonitorDataState">
<Value name="1">
<Value>ID</Value>
</Value>
<Value name="2">
<Value>AuditIndex</Value>
</Value>
<Value name="3">
<Value>Authentication</Value>
</Value>
<Value name="4">
<Value>CSPSessionID</Value>
</Value>
<Value name="5">
<Value>ClientExecutableName</Value>
</Value>
<Value name="6">
<Value>ClientIPAddress</Value>
</Value>
<Value name="7">
<Value>Description</Value>
</Value>
<Value name="8">
<Value>Event</Value>
</Value>
<Value name="9">
<Value>EventData</Value>
</Value>
<Value name="10">
<Value>EventSource</Value>
</Value>
<Value name="11">
<Value>EventType</Value>
</Value>
<Value name="12">
<Value>GroupName</Value>
</Value>
<Value name="13">
<Value>JobId</Value>
</Value>
<Value name="14">
<Value>JobNumber</Value>
</Value>
<Value name="15">
<Value>Namespace</Value>
</Value>
<Value name="16">
<Value>OSUsername</Value>
</Value>
<Value name="17">
<Value>Pid</Value>
</Value>
<Value name="18">
<Value>Roles</Value>
</Value>
<Value name="19">
<Value>RoutineSpec</Value>
</Value>
<Value name="20">
<Value>Status</Value>
</Value>
<Value name="21">
<Value>SystemID</Value>
</Value>
<Value name="22">
<Value>UTCTimeStamp</Value>
</Value>
<Value name="23">
<Value>UserInfo</Value>
</Value>
<Value name="24">
<Value>Username</Value>
</Value>
</Data>
<State>AuditMonitorDataState</State>
<StreamLocation>^IRISELK.Audit.AuditMonitorDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
