/// Description
Class IRISELK.System.Data.DbDataRequest Extends IRISELK.Messages.LogstashRequest
{

Property DbData As list Of IRISELK.System.Data.DbData;

Storage Default
{
<Data name="DbDataRequestDefaultData">
<Subscript>"DbDataRequest"</Subscript>
<Value name="1">
<Value>DbData</Value>
</Value>
</Data>
<DefaultData>DbDataRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
