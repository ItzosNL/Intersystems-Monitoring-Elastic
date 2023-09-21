/// Business Operation that sends information to Elastic via Logstash
Class IRISELK.BusinessOperation.LogstashOutbound Extends Ens.BusinessOperation [ Language = objectscript ]
{

Parameter ADAPTER = "EnsLib.HTTP.OutboundAdapter";

Property Adapter As EnsLib.HTTP.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// OTAP Purpose of this instance
Property InstanceOTAP As %String(VALUELIST = ",dev,tst,acc,prd,other");

/// Optional description of the instance
Property InstanceDescription As %String;

/// Name of the client for who this server is for
Property ServerClientName As %String;

/// Additional Settings
Parameter SETTINGS = "InstanceOTAP:Basic,InstanceDescription:Basic,ServerClientName:Basic";

/// Common method to send a message to Logstash as JSON
Method SendToLogstash(pRequest As Ens.Request, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	// Convert message to JSON
	set jsonstring = ""
	do pRequest.%JSONExportToString(.jsonstring)
	$$$TRACE(jsonstring)

	// Fetch configMap items
	#dim config as %DynamicObject = ##class(IRISELK.BusinessOperation.Config).Load(.sc)

	// Create request and response objects
	set tResponse = ##class(%Net.HttpResponse).%New()
	set tRequest = ##class(%Net.HttpRequest).%New()

	do ..SetHeaders(tRequest, config)

	// POST message in JSON to Logstash
	if $ISOBJECT(config)
	{
		$$$TRACE("Send to logstash at '" _ config."logstash-url" _ "': ")
		// Fill adapter from config
		set ..Adapter.SSLConfig = config.%Get("logstash-ssl-config", "Default")
		set ..Adapter.SSLCheckServerIdentity = config."logstash-check-server-identity"
		do ..SetProxy(config."logstash-proxy-address")

		/// Use url from config
		set sc = ..Adapter.SendFormDataArray(.tResponse, "POST", tRequest, , .jsonstring, config."logstash-url")
	}
	else
	{
		/// Use hardwired config
		set sc = ..Adapter.SendFormData(.tResponse, "POST", tRequest, , jsonstring)
	}

	set pResponse = ##class(IRISELK.Messages.MonitorResponse).%New()
	
	if $$$ISOK(sc)
	{
		// Create monitor response
		set data = tResponse.Data.Read()
		$$$TRACE("status " _ data)
		set pResponse.Data = data
	}
	else
	{
		$$$LOGERROR("Error when communicating with Elastic: " _ $System.Status.GetErrorText(sc))
	}

	return $$$OK
}

/// Set Proxy
Method SetProxy(proxyAddress As %String)
{
	if (proxyAddress '= "")
	{
		$$$TRACE("Set proxy to '" _ proxyAddress _ "': ")

		set ..Adapter.ProxyHTTPS = ..StartsWith(proxyAddress, "https://")
		
		if (..Adapter.ProxyHTTPS)
		{
			set prefix = "https://"
		}
		else
		{
			set prefix = "http://"
		}

		set serverAndPort = $REPLACE(proxyAddress, prefix, "")
		set ..Adapter.ProxyServer = $PIECE(serverAndPort, ":", 1)
		set port = $PIECE(serverAndPort, ":", 2)
		
		if (port '= "")
		{
			set ..Adapter.ProxyPort = port
		}
	}
}

/// StartsWith helper
ClassMethod StartsWith(sourceValue As %String, searchValue As %String) As %Boolean
{
    set pattern = "1"""_searchValue_"""0.E"

    return (sourceValue ? @pattern )
}

/// set headers
Method SetHeaders(tRequest As %Net.HttpRequest, config As %DynamicObject)
{
	do ..SetHeader(tRequest, "server_name", ##class(IRISELK.Util.Hostname).GetServiceOrHostName(.ns))

	if ns '= ""
	{
		do ..SetHeader(tRequest, "k8s_namespace", ns)
	}

	do ..SetHeader(tRequest, "instance_name", $ZCONVERT(##class(%SYS.System).GetInstanceName(), "L"))
	do ..SetHeader(tRequest, "instance_product_type", $CASE($LTS($system.Version.GetISCComponents()), "Health": "IRIS for Health", "HealthConnect":"HealthConnect", :"IRIS"))

	if $ISOBJECT(config)
	{
		do ..SetHeader(tRequest, "instance_otap", config.stage) // expected values: dev|tst|acc|prd|other
		do ..SetHeader(tRequest, "instance_description", config.description)
		do ..SetHeader(tRequest, "server_client_name", config.customer)
	}
	else
	{
		// Backwards compatibility
		do ..SetHeader(tRequest, "instance_otap", ..InstanceOTAP)
		do ..SetHeader(tRequest, "instance_description", ..InstanceDescription)
		do ..SetHeader(tRequest, "server_client_name", ..ServerClientName)
	}
}

/// SetHeader with optional logging
ClassMethod SetHeader(tRequest As %Net.HttpRequest, name As %String, value As %String) As %Status
{
	do tRequest.SetHeader(name, value)

	$$$TRACE(name _ "=" _ value)
}

Method SendLoginInfo(pRequest As IRISELK.Audit.AuditMonitorRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

Method SendSystemInfo(pRequest As IRISELK.System.SystemMonitorRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

Method SendProductionInfo(pRequest As IRISELK.ProductionData.ProductionMonitorRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

Method SendEventLog(pRequest As IRISELK.EventLog.EventLogRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

Method SendHeaderInfo(pRequest As IRISELK.Header.HeaderMonitorRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

Method SendTaskInfo(pRequest As IRISELK.Task.TaskMonitorRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

Method SendLicenseInfo(pRequest As IRISELK.License.LicenseMonitorRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	do ..SendToLogstash(pRequest, pResponse)
	return $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="IRISELK.Audit.AuditMonitorRequest"> 
		<Method>SendLoginInfo</Method>
	</MapItem>
	<MapItem MessageType="IRISELK.System.SystemMonitorRequest"> 
		<Method>SendSystemInfo</Method>
	</MapItem>
	<MapItem MessageType="IRISELK.ProductionData.ProductionMonitorRequest"> 
		<Method>SendProductionInfo</Method>
	</MapItem>
	<MapItem MessageType="IRISELK.EventLog.EventLogRequest"> 
		<Method>SendEventLog</Method>
	</MapItem>
	<MapItem MessageType="IRISELK.Header.HeaderMonitorRequest"> 
		<Method>SendHeaderInfo</Method>
	</MapItem>
	<MapItem MessageType="IRISELK.Task.TaskMonitorRequest"> 
		<Method>SendTaskInfo</Method>
	</MapItem>
	<MapItem MessageType="IRISELK.License.LicenseMonitorRequest"> 
		<Method>SendLicenseInfo</Method>
	</MapItem>
</MapItems>
}

}
