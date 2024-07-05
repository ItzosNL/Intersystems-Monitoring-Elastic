Class IRISELK.ErrorHandler.Data.ErrorData Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

Property ID As %BigInt;

Property ConfigName As %String(MAXLEN = 128);

Property Job As %String;

Property MessageId As %Integer;

Property SessionId As %Integer;

Property SourceClass As %String(MAXLEN = 255);

Property SourceMethod As %String;

Property Stack As %String(MAXLEN = 10000);

Property Text As %String(MAXLEN = 32000);

Property TimeLogged As %TimeStamp;

Property Type As %String;

Property Namespace As %String;

Property SourceCode As %String;

Property Prio As %Integer;

Storage Default
{
<Data name="ErrorDataState">
<Value name="1">
<Value>ID</Value>
</Value>
<Value name="2">
<Value>ConfigName</Value>
</Value>
<Value name="3">
<Value>Job</Value>
</Value>
<Value name="4">
<Value>MessageId</Value>
</Value>
<Value name="5">
<Value>SessionId</Value>
</Value>
<Value name="6">
<Value>SourceClass</Value>
</Value>
<Value name="7">
<Value>SourceMethod</Value>
</Value>
<Value name="8">
<Value>Stack</Value>
</Value>
<Value name="9">
<Value>Text</Value>
</Value>
<Value name="10">
<Value>TimeLogged</Value>
</Value>
<Value name="11">
<Value>Type</Value>
</Value>
<Value name="12">
<Value>Namespace</Value>
</Value>
<Value name="13">
<Value>SourceCode</Value>
</Value>
<Value name="14">
<Value>Prio</Value>
</Value>
</Data>
<State>ErrorDataState</State>
<StreamLocation>^IRISELK.ErrorHanF6BA.ErrorDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
