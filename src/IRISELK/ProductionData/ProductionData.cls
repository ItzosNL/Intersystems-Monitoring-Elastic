Class IRISELK.ProductionData.ProductionData Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor)
{

Property NameSpace As %String;

Property ProductionName As %String(MAXLEN = 500);

Property Status As %String;

Property LastStartTime As %String [ InitialExpression = "Never started" ];

Property LastStopTime As %String [ InitialExpression = "Never stopped" ];

Property StatusEnum As %Integer;

Storage Default
{
<Data name="ProductionDataState">
<Value name="1">
<Value>NameSpace</Value>
</Value>
<Value name="2">
<Value>ProductionName</Value>
</Value>
<Value name="3">
<Value>Status</Value>
</Value>
<Value name="4">
<Value>LastStartTime</Value>
</Value>
<Value name="5">
<Value>LastStopTime</Value>
</Value>
<Value name="6">
<Value>StatusEnum</Value>
</Value>
</Data>
<State>ProductionDataState</State>
<StreamLocation>^IRISELK.ProductionData.ProductionDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
