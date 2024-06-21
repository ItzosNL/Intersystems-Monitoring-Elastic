Class IRISELK.ErrorHandler.Data.ErrorRequest Extends (Ens.Request, %JSON.Adaptor) [ Language = objectscript ]
{

Property Errorhandler As list Of IRISELK.ErrorHandler.Data.ErrorData;

Storage Default
{
<Data name="ErrorRequestDefaultData">
<Subscript>"ErrorhandlerRequest"</Subscript>
<Value name="1">
<Value>Errorhandler</Value>
</Value>
</Data>
<DefaultData>ErrorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
