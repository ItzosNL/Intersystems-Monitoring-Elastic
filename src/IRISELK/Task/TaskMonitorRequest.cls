Class IRISELK.Task.TaskMonitorRequest Extends IRISELK.Messages.LogstashRequest [ Language = objectscript ]
{

Property TaskData As list Of IRISELK.Task.TaskData;

Storage Default
{
<Data name="TaskMonitorRequestDefaultData">
<Subscript>"TaskMonitorRequest"</Subscript>
<Value name="1">
<Value>TaskData</Value>
</Value>
</Data>
<DefaultData>TaskMonitorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
