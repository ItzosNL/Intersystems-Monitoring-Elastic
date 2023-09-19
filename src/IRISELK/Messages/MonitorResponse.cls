Class IRISELK.Messages.MonitorResponse Extends Ens.Response [ Language = objectscript ]
{

Property Data As %RawString;

Property StatusCode As %Integer;

Property ReasonPhrase As %String;

Storage Default
{
<Data name="MonitorResponseDefaultData">
<Subscript>"MonitorResponse"</Subscript>
<Value name="1">
<Value>Data</Value>
</Value>
<Value name="2">
<Value>StatusCode</Value>
</Value>
<Value name="3">
<Value>ReasonPhrase</Value>
</Value>
</Data>
<DefaultData>MonitorResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
