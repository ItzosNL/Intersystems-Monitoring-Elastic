Class IRISELK.EventLog.EventLogRequest Extends (Ens.Request, %JSON.Adaptor) [ Language = objectscript ]
{

Property EventLogData As list Of IRISELK.EventLog.EventLogData;

Storage Default
{
<Data name="EventLogRequestDefaultData">
<Subscript>"EventLogRequest"</Subscript>
<Value name="1">
<Value>EventLogData</Value>
</Value>
</Data>
<DefaultData>EventLogRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
