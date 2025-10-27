Include %occErrors

/// Loads config.json
/// For example see config/config.json
Class IRISELK.BusinessOperation.Config
{

/// Node from the after-install.config processed by this class.
Parameter AfterInstallNode = "monitoring";

/// Requires filename instead of DynamicObject 
Parameter AfterInstallMode = "file";

/// Load config
ClassMethod LoadFile(filename As %String)
{
    new $NAMESPACE
    set $NAMESPACE = "MONITORING"

    do ..SetConfig(filename)

    // Only start the production if it is enabled!

    set config = ..Load(.sc)

    if $$$ISERR(sc) || ((config.enabled '= "") && (config.enabled = 0))
    {
        // In case of a configuration error, or when disabled, stop production and remove autostart
        do ##class(IRISELK.Setup.installer).StopProduction()
    }
    else
    {
        // Start production and make autostartable
        do ##class(IRISELK.Setup.installer).AutoStartProduction()
    }
}

/// SetConfig - pass in the json config file name
ClassMethod SetConfig(filename As %String = {##class(%SYSTEM.Util).ManagerDirectory() _ "config.json"})
{
    write "Monitoring.SetConfig(""",filename,""") in namespace ",$NAMESPACE,!
    set ^AAISMonitoringConfig = filename
}

/// Load config from file
ClassMethod Load(Output sc As %Status, section As %String = "monitoring") As %DynamicObject
{
	set sc = $$$OK
	#dim json as %DynamicObject = ""

    if $GET(^AAISMonitoringConfig) '= ""
    {
        try
        {   
            set stream = ##class(%Stream.FileCharacter).%New()
            set sc = stream.LinkToFile(^AAISMonitoringConfig)
            set json = ##class(%DynamicAbstractObject).%FromJSON(stream)
 
            if $ISOBJECT(json.%Get(section))
            {
                return json.%Get(section)
            }
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
