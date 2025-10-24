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
Method SendToLogstash(pRequest As IRISELK.Messages.LogstashRequest, Output pResponse As IRISELK.Messages.MonitorResponse) As %Status
{
	// Fetch configMap items
	#dim config as %DynamicObject = ##class(IRISELK.BusinessOperation.Config).Load(.sc)

	// Create request and response objects
	set tResponse = ##class(%Net.HttpResponse).%New()
	set tRequest = ##class(%Net.HttpRequest).%New()

	do pRequest.%JSONExportToStream(tRequest.EntityBody)
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
		set sc = ..Adapter.SendFormDataArray(.tResponse, "POST", tRequest, , , config."logstash-url")
	}
	else
	{
		/// Use hardwired config
		set sc = ..Adapter.SendFormData(.tResponse, "POST", tRequest)
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
	do ..SetHeader(tRequest, "mp_version", ..GetPackageVersion())
	do ..SetHeader(tRequest, "iris_version", $system.Version.Format(3))

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

/// Get current Version of Monitoring package
ClassMethod GetPackageVersion(packageName As %String = "intersystems-monitoring") As %String
{
	if '##class(%Dictionary.CompiledClass).%ExistsId("%ZPM.PackageManager.Developer.Module")
	{
		// Don't error in namespaces with later versions that use %IPM
		return ..GetIPMPackageVersion(packageName)
	}

	#dim result as %SQL.StatementResult = ##class(%SQL.Statement).%ExecDirect(, "SELECT VersionString FROM %ZPM_PackageManager_Developer.""Module"" WHERE Name = ?", packageName)

	if (result.%SQLCODE < 0)
	{
		throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
	}

	if result.%Next()
	{
		return result.VersionString
	}

	return ""
}

/// Get current Version of specified package
ClassMethod GetIPMPackageVersion(packageName As %String) As %String
{
	if '$$$comClassDefined("%IPM.Storage.Module")
	{
		// Don't error in namespaces without IPM enabled
		return ""
	}

	#dim result as %SQL.StatementResult = ##class(%SQL.Statement).%ExecDirect(, "SELECT VersionString FROM %IPM_Storage.ModuleItem WHERE Name = ?", packageName)

	if (result.%SQLCODE < 0)
	{
		throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,result.%Message)
	}

	if result.%Next()
	{
		return result.VersionString
	}

	return ""
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="IRISELK.Messages.LogstashRequest"> 
		<Method>SendToLogstash</Method>
	</MapItem>
</MapItems>
}

}
