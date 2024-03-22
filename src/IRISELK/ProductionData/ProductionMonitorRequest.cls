Class IRISELK.ProductionData.ProductionMonitorRequest Extends IRISELK.Messages.LogstashRequest [ Language = objectscript ]
{

Property ProductionData As list Of IRISELK.ProductionData.ProductionData;

Storage Default
{
<Data name="ProductionData">
<Attribute>ProductionData</Attribute>
<Structure>subnode</Structure>
<Subscript>"IRISELK.ProductionData.ProductionMonitorRequest.ProductionData"</Subscript>
</Data>
<Type>%Storage.Persistent</Type>
}

}
