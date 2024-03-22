Class IRISELK.System.SystemMonitorRequest Extends IRISELK.Messages.LogstashRequest [ Language = objectscript ]
{

Property MonitorData As array Of %Double;

/// Get System metrics
ClassMethod GetMetrics() As IRISELK.System.SystemMonitorRequest
{
	set req = ##class(IRISELK.System.SystemMonitorRequest).%New()
	NEW $Namespace
	set $Namespace = "%SYS"
    set metrics = ##class(SYS.Monitor.SAM.Sensors).PrometheusMetrics()
	set metricslist = $LISTFROMSTRING(metrics, $CHAR(10))

	set ptr = 0
	while $LISTNEXT(metricslist, ptr, line)
	{
		// Remove all punctation, except specified symbols (remove quotation marks for JSON validation)
		set line = $ZSTRIP(line, "*P'W",, "_.:{}=")
		set key = $PIECE(line," ", 1)
		set val = $PIECE(line," ", 2)
        
        if (key '= "")
        {
            #; write key,"=",val,!
            do req.MonitorData.SetAt(val, key)
        }
	}

	return req
}

Storage Default
{
<Data name="MonitorData">
<Attribute>MonitorData</Attribute>
<Structure>subnode</Structure>
<Subscript>"IRISELK.System.SystemMonitorRequest.MonitorData"</Subscript>
</Data>
<Type>%Storage.Persistent</Type>
}

}
