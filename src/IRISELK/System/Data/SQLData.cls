/// Description
Class IRISELK.System.Data.SQLData Extends IRISELK.Messages.LogstashRequest
{

Property Namespace As %String;

Property SqlQueriesAvgRuntime As %Double;

Property SqlQueriesAvgRuntimeStdDev As %Double;

Property SqlQueriesPerSecond As %Double;

Property SqlRowCountPerSecond As %Double;

Storage Default
{
<Data name="SQLDataDefaultData">
<Subscript>"SQLData"</Subscript>
<Value name="1">
<Value>Namespace</Value>
</Value>
<Value name="2">
<Value>SqlQueriesAvgRuntime</Value>
</Value>
<Value name="3">
<Value>SqlQueriesAvgRuntimeStdDev</Value>
</Value>
<Value name="4">
<Value>SqlQueriesPerSecond</Value>
</Value>
<Value name="5">
<Value>SqlRowCountPerSecond</Value>
</Value>
</Data>
<DefaultData>SQLDataDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
