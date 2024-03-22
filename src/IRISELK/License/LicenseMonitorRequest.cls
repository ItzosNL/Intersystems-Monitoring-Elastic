Class IRISELK.License.LicenseMonitorRequest Extends IRISELK.Messages.LogstashRequest [ Language = objectscript ]
{

Property LicenseData As list Of IRISELK.License.LicenseData;

Storage Default
{
<Data name="LicenseMonitorRequestDefaultData">
<Subscript>"LicenseMonitorRequest"</Subscript>
<Value name="1">
<Value>LicenseData</Value>
</Value>
</Data>
<DefaultData>LicenseMonitorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
