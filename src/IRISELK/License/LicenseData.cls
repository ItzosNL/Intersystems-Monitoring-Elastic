Class IRISELK.License.LicenseData Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

Property LicenseInfo As %String(%JSONFIELDNAME = "license_info", MAXLEN = 500);

Property ExpirationDate As %String(%JSONFIELDNAME = "expiration_date");

Property DaysUntilExpire As %Integer(%JSONFIELDNAME = "days_until_expire");

Storage Default
{
<Data name="LicenseDataState">
<Value name="1">
<Value>LicenseInfo</Value>
</Value>
<Value name="2">
<Value>ExpirationDate</Value>
</Value>
<Value name="3">
<Value>DaysUntilExpire</Value>
</Value>
</Data>
<State>LicenseDataState</State>
<StreamLocation>^IRISELK.License.LicenseDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
