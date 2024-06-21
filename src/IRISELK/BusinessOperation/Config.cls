Include %occErrors

/// Loads config.json
/// For example see config/config.json
Class IRISELK.BusinessOperation.Config
{

/// SetConfig - pass in the json config file name
ClassMethod SetConfig(filename As %String = {##class(%SYSTEM.Util).ManagerDirectory() _ "config.json"})
{
    set ^AAISMonitoringConfig = filename
}

/// Load confog from file
ClassMethod Load(Output sc As %Status) As %DynamicObject
{
	set sc = $$$OK
	set json = ""

    if $GET(^AAISMonitoringConfig) '= ""
    {
        try
        {
            set json = {}.%FromJSONFile(^AAISMonitoringConfig)
        }
        catch error
        {
            set sc = error.AsStatus()
            w "Failed loading config from " _ ^AAISMonitoringConfig _ ": "
            do $SYSTEM.Status.DisplayError(sc)
        }
    }
    else
    {
        set sc = $System.Status.Error($$$GeneralError, "Global ^AAISMonitoringConfig has not been configured")
	
    }

    if $ISOBJECT(json.monitoring)
    {
        return json.monitoring
    }

	return json
}

/// Print configuration
ClassMethod Print() As %Status
{
	set config = ..Load(.sc)

	if $$$ISERR(sc)
    {
		do $SYSTEM.Status.DisplayError(sc)
        return sc
	}

    // Now use the settings!
    w "stage: ", config.stage,!
    w "description: ", config.description,!
    w "customer: ", config.customer,!
    w "logstash-url: ", config."logstash-url",!
    w "ssl-config: ", config."logstash-ssl-config",!
    w "check-server-identity: ", config."logstash-check-server-identity",!
    w "proxy: ", config."logstash-proxy-address",!

	return sc
}

}
