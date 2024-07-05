Class IRISELK.ErrorHandler.Data.ErrorRequest Extends IRISELK.Messages.LogstashRequest [ Language = objectscript ]
{

Property ErrorData As list Of IRISELK.ErrorHandler.Data.ErrorData;

Storage Default
{
<Data name="ErrorRequestDefaultData">
<Subscript>"ErrorRequest"</Subscript>
<Value name="1">
<Value>ErrorData</Value>
</Value>
</Data>
<DefaultData>ErrorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
