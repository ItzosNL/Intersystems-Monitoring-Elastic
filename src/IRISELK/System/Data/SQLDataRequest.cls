Class IRISELK.System.Data.SQLDataRequest Extends IRISELK.Messages.LogstashRequest
{

Property SQLData As list Of IRISELK.System.Data.SQLData;

Storage Default
{
<Data name="SQLDataRequestDefaultData">
<Subscript>"SQLDataRequest"</Subscript>
<Value name="1">
<Value>SQLData</Value>
</Value>
</Data>
<DefaultData>SQLDataRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
