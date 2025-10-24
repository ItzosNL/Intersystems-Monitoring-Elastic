/// Gather and send Promotheus Metrics
Class IRISELK.System.SystemMonitorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Called every time the CallInterval expires
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	set sysDataReq = ##class(IRISELK.System.SystemMonitorRequest).SysMetrics()

	return ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", sysDataReq)
}

}
