Class IRISELK.Header.HeaderData Extends (%SerialObject, %XML.Adaptor, %JSON.Adaptor, Ens.MessageHeaderBase)
{

Property ID As %BigInt;

Property Namespace As %String;

Property InvocationDisplay As %String;

Property TypeDisplay As %String;

Property PriorityDisplay As %String;

Property StatusDisplay As %String;

Property SourceBusinessTypeDisplay As %String;

Property TargetBusinessTypeDisplay As %String;

Property ErrorStatusDisplay As %String(MAXLEN = 500);

Property TimeProcessedDiff As %Double;

Storage Default
{
<Data name="HeaderDataState">
<Value name="1">
<Value>Type</Value>
</Value>
<Value name="2">
<Value>Priority</Value>
</Value>
<Value name="3">
<Value>Invocation</Value>
</Value>
<Value name="4">
<Value>TimeCreated</Value>
</Value>
<Value name="5">
<Value>TimeProcessed</Value>
</Value>
<Value name="6">
<Value>Status</Value>
</Value>
<Value name="7">
<Value>IsError</Value>
</Value>
<Value name="8">
<Value>ErrorStatus</Value>
</Value>
<Value name="9">
<Value>CorrespondingMessageId</Value>
</Value>
<Value name="10">
<Value>SessionId</Value>
</Value>
<Value name="11">
<Value>SourceConfigName</Value>
</Value>
<Value name="12">
<Value>TargetConfigName</Value>
</Value>
<Value name="13">
<Value>SourceBusinessType</Value>
</Value>
<Value name="14">
<Value>TargetBusinessType</Value>
</Value>
<Value name="15">
<Value>BusinessProcessId</Value>
</Value>
<Value name="16">
<Value>TargetQueueName</Value>
</Value>
<Value name="17">
<Value>ReturnQueueName</Value>
</Value>
<Value name="18">
<Value>MessageBodyClassName</Value>
</Value>
<Value name="19">
<Value>MessageBodyId</Value>
</Value>
<Value name="20">
<Value>Description</Value>
</Value>
<Value name="21">
<Value>SuperSession</Value>
</Value>
<Value name="22">
<Value>Resent</Value>
</Value>
<Value name="33">
<Value>Namespace</Value>
</Value>
<Value name="34">
<Value>ID</Value>
</Value>
<Value name="35">
<Value>InvocationDisplay</Value>
</Value>
<Value name="36">
<Value>TypeDisplay</Value>
</Value>
<Value name="37">
<Value>PriorityDisplay</Value>
</Value>
<Value name="39">
<Value>SourceBusinessTypeDisplay</Value>
</Value>
<Value name="40">
<Value>TargetBusinessTypeDisplay</Value>
</Value>
<Value name="41">
<Value>StatusDisplay</Value>
</Value>
<Value name="42">
<Value>ErrorStatusDisplay</Value>
</Value>
<Value name="43">
<Value>TimeProcessedDiff</Value>
</Value>
</Data>
<State>HeaderDataState</State>
<StreamLocation>^IRISELK.Header.HeaderDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
