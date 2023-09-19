Class IRISELK.Header.HeaderMonitorRequest Extends (Ens.Request, %JSON.Adaptor) [ Language = objectscript ]
{

Property HeaderData As list Of IRISELK.Header.HeaderData;

Storage Default
{
<Data name="HeaderMonitorRequestDefaultData">
<Subscript>"HeaderMonitorRequest"</Subscript>
<Value name="1">
<Value>HeaderData</Value>
</Value>
</Data>
<DefaultData>HeaderMonitorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
