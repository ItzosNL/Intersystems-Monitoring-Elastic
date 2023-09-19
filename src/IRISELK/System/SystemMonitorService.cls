/// Gather and send Promotheus Metrics
Class IRISELK.System.SystemMonitorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Called every time the CallInterval expires
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	set req = ##class(IRISELK.System.SystemMonitorRequest).GetMetrics()

	return ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)
}

}
