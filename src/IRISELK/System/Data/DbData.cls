/// Description
Class IRISELK.System.Data.DbData Extends IRISELK.Messages.LogstashRequest
{

Property NameSpace As %String;

Property DbSizeMb As %Double;

Storage Default
{
<Data name="DbDataDefaultData">
<Subscript>"DbData"</Subscript>
<Value name="1">
<Value>NameSpace</Value>
</Value>
<Value name="2">
<Value>DbSizeMb</Value>
</Value>
<Value name="3">
<Value>SqlQueriesAvgRuntime</Value>
</Value>
<Value name="4">
<Value>SqlQueriesAvgRuntimeStdDev</Value>
</Value>
<Value name="5">
<Value>SqlQueriesPerSecond</Value>
</Value>
<Value name="6">
<Value>SqlRowCountPerSecond</Value>
</Value>
</Data>
<DefaultData>DbDataDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
