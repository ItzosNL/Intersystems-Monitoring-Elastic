Class IRISELK.System.SystemMonitorRequest Extends IRISELK.Messages.LogstashRequest [ Language = objectscript ]
{

Property MonitorData As IRISELK.System.Data.MonitoringData;

ClassMethod ExtractInfo(key As %String, Extraction As %String) As %String
{
    if (Extraction = "dir"){

        set locatebegin = $LOCATE(key, "dir={1}")
        set locateEnd = $LOCATE(key, "\}{1}")
        if (locatebegin '= 0){
            set extract = $EXTRACT(key, (locatebegin+4), (locateEnd-1))
            set dir = extract
        } else { set dir = ""}

        Return dir
    } elseif (Extraction = "namespace"){

        set keyInfo = $PIECE(key, "{", 2) 
        set locateStart = $LOCATE(keyInfo, "id={1}")
        set locateEnd = $LOCATE(keyInfo, ",dir={1}")
        if (locateEnd = 0){
            set nameSpace = $EXTRACT(keyInfo, (locateStart+4), *-2)
        } else {set nameSpace = $EXTRACT(keyInfo, (locateStart+4), (locateEnd-2))}

        return nameSpace
    }
}

ClassMethod FilterPropertys(PropertyName As %String) As %Boolean
{

    set propertyList = ["SqlQueriesAvgRuntime", "SqlQueriesAvgRuntimeStdDev", "SqlQueriesPerSecond","SqlRowCountPerSecond"]
    set iter = propertyList.%GetIterator()

    while iter.%GetNext(.key, .value) {
        if (PropertyName = value){
            return 1
        }
    }

    return 0
}

ClassMethod FormatKey(key As %String) As %String
{

    set keyName = $PIECE(key, "{", 1) 
    set removeIris = $REPLACE(keyName, "iris_", "")
    set noUnderScore = $REPLACE(removeIris, "_", " ")
    set capitalize = $ZCONVERT(noUnderScore, "W")
    set strip = $ZSTRIP(capitalize, "*W")

    return strip
}

ClassMethod ReturnMetricList() As %List
{

    NEW $Namespace
	set $Namespace = "%SYS"
    set metrics = ##class(SYS.Monitor.SAM.Sensors).PrometheusMetrics()
    set metricslist = $LISTFROMSTRING(metrics, $CHAR(10))
    set $Namespace = "MONITORING"

    return metricslist
}

ClassMethod SQLData() As IRISELK.System.Data.SQLDataRequest
{
   
    // Start with filtering out only the DB data from the list.

    set req = ##class(IRISELK.System.Data.SQLDataRequest).%New()
    
    set metricslist = ..ReturnMetricList()
    set SqlQueriesAvgRtList = ##class(%ListOfDataTypes).%New()
    set SqlQueriesAvgRtStdDevList = ##class(%ListOfDataTypes).%New()
    set SqlQueriesList = ##class(%ListOfDataTypes).%New()
    set SqlRowCountList = ##class(%ListOfDataTypes).%New()

    set ptr = 0
	while $LISTNEXT(metricslist, ptr, line)
	{
        set key = $PIECE(line," ", 1)
		set val = $PIECE(line," ", 2)

        set strip = ..FormatKey(key)

        if (..FilterPropertys(strip)){

            set nameSpace = ..ExtractInfo(key, "namespace")
            set dataString = nameSpace _ " " _ val

            if (strip = "SqlQueriesAvgRuntime"){
                do SqlQueriesAvgRtList.Insert(dataString)
            } elseif (strip = "SqlQueriesAvgRuntimeStdDev"){
                do SqlQueriesAvgRtStdDevList.Insert(dataString)
            } elseif (strip = "SqlQueriesPerSecond"){
                do SqlQueriesList.Insert(dataString)
            } elseif (strip = "SqlRowCountPerSecond"){
                do SqlRowCountList.Insert(dataString)
            }
        
        }
    }

    for i=1:1:SqlQueriesAvgRtList.Count(){
        set SQLData = ##class(IRISELK.System.Data.SQLData).%New()

        set string = SqlQueriesAvgRtList.GetAt(i)
        set nameSpace = $PIECE(string," ", 1)
		set value = $PIECE(string," ", 2)
        set SQLData.Namespace = nameSpace
        set SQLData.SqlQueriesAvgRuntime = value 

        set string = SqlQueriesAvgRtStdDevList.GetAt(i)
		set value = $PIECE(string," ", 2)
        set SQLData.SqlQueriesAvgRuntimeStdDev = value

        set string = SqlQueriesList.GetAt(i)
		set value = $PIECE(string," ", 2)
        set SQLData.SqlQueriesPerSecond = value

        set string = SqlRowCountList.GetAt(i)
		set value = $PIECE(string," ", 2)
        set SQLData.SqlRowCountPerSecond = value

        do req.SQLData.Insert(SQLData)
    }
    
    return req
}

ClassMethod DbSize() As IRISELK.System.Data.DbDataRequest
{
    set req = ##class(IRISELK.System.Data.DbDataRequest).%New()
    set metricslist = ..ReturnMetricList()

    set ptr = 0
	while $LISTNEXT(metricslist, ptr, line)
	{
        set key = $PIECE(line," ", 1)
		set val = $PIECE(line," ", 2)

        set strip = ..FormatKey(key)

        if (strip = "DbSizeMb"){
            set DbData = ##class(IRISELK.System.Data.DbData).%New()
            // if needed to filter more -> make a new list with only DB data
            set nameSpace = ..ExtractInfo(key, "namespace")

            set DbData.NameSpace = nameSpace
            set DbData.DbSizeMb = val

            do req.DbData.Insert(DbData)
        }
        
    }

    return req
}

ClassMethod SysMetrics() As IRISELK.System.SystemMonitorRequest
{

    set sysData = ##class(IRISELK.System.Data.MonitoringData).%New()
    set propertyList = ##class(%Library.CompiledClass).%OpenId("IRISELK.System.Data.MonitoringData")

    set req = ##class(IRISELK.System.SystemMonitorRequest).%New()

    set metricslist = ..ReturnMetricList()

    set previousePropertyName = ""
    set incr = 1
    set previouseVal = 0
    
    set ptr = 0
	while $LISTNEXT(metricslist, ptr, line)
	{
		set key = $PIECE(line," ", 1)
		set val = $PIECE(line," ", 2)

        set strip = ..FormatKey(key)

        if (..FilterPropertys(strip)){
            continue
        }

        for i=3:1:propertyList.Properties.Count() {
            set propertyName = propertyList.Properties.GetAt(i).Name

            if (strip = propertyName){

                set propRef = $PROPERTY(sysData, propertyName)
                set propType = propertyList.Properties.GetAt(i).Type

                // Voor alle data points met de zelfde naam, maar andere data.
                if (propType = "%Library.DataType"){
                
                    if (propertyName '= previousePropertyName){
                        set incr = 1
                    }

                    set propKey = propertyName _ "_" _ incr

                    // Specifieke filter voor disk space percent.
                    if (propertyName = "DiskPercentFull"){

                        if $ZVERSION(1) = 2
                        {   
                            set dirPath = ..ExtractInfo(key, "dir")
                            set piecedDirPath = $PIECE(dirPath, "\\")
                            set disk = $EXTRACT(piecedDirPath, 2, *)
                        }
                        else 
                        {
                            set dirPath = ..ExtractInfo(key, "dir")
                            set disk = $ZSTRIP(dirPath, "*","""")
                        }
                        
                        if '(sysData.DiskPercentFull.IsDefined("DiskPercentFull_1")){
                            do sysData.DiskPercentFull.SetAt(disk, "DirName1")
                            do propRef.SetAt(val, propKey)
                            set diskspace1 = sysData.DiskPercentFull.GetAt("DiskPercentFull_1")
                        } elseif (val = diskspace1){
                            do sysData.DiskPercentFull.SetAt(disk, "DirName1")
                            do propRef.SetAt(val, propKey)
                            
                        } else {
                            set incr = incr + 1
                            do sysData.DiskPercentFull.SetAt(disk, "DirName2")
                            do propRef.SetAt(val, propKey)
                        }
                    } else {
                        // Voor alle andere data points
                        do propRef.SetAt(val, propKey) 
                        set incr = incr + 1
                    }
                   
                    set previousePropertyName = propertyName
                    quit
                } else { set $PROPERTY(sysData, propertyName) = val q}
                
            }


        }        
        
	}
    set req.MonitorData = sysData

    return req
}

Storage Default
{
<Data name="MonitorData">
<Attribute>MonitorData</Attribute>
<Structure>subnode</Structure>
<Subscript>"IRISELK.System.SystemMonitorRequest.MonitorData"</Subscript>
</Data>
<Data name="SystemMonitorRequestDefaultData">
<Subscript>"SystemMonitorRequest"</Subscript>
<Value name="1">
<Value>value</Value>
</Value>
<Value name="2">
<Value>id</Value>
</Value>
<Value name="3">
<Value>path</Value>
</Value>
<Value name="4">
<Value>key</Value>
</Value>
</Data>
<DefaultData>SystemMonitorRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
