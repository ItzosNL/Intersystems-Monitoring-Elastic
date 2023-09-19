Class IRISELK.Audit.AuditMonitorRequest Extends (Ens.Request, %JSON.Adaptor) [ Language = objectscript ]
{

Property AuditData As list Of IRISELK.Audit.AuditMonitorData;

Storage Default
{
<Data name="AuditMonitorRequestDefaultData">
<Subscript>"AuditMonitorRequest"</Subscript>
<Value name="1">
<Value>AuditData</Value>
</Value>
</Data>
<DefaultData>AuditMonitorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
