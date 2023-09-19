/// Gather and send Production name and status
Class IRISELK.ProductionData.ProductionMonitorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Called every time the CallInterval expires
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
    set req = ..GetProductDataForAllNamespaces()

	do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)

	return $$$OK
}

/// Get production data for all namespaces
ClassMethod GetProductDataForAllNamespaces() As IRISELK.ProductionData.ProductionMonitorRequest
{
    set namespaces = ..GetSupportedNamespaces()

	set req = ##class(IRISELK.ProductionData.ProductionMonitorRequest).%New()

    for i = 1:1:namespaces.Count()
    {
        set prddata =  ..GetProductionInformation(namespaces.GetAt(i))

        if (prddata '= "")
        {
            do req.ProductionData.Insert(prddata)
        }
    }

	return req
}

/// Get Production Information in the specified namespace
ClassMethod GetProductionInformation(namespace As %String) As IRISELK.ProductionData.ProductionData
{
    new $NAMESPACE
    set $NAMESPACE = namespace

    set prdRS = ##class(%ResultSet).%New("Ens.Config.Production:ProductionStatus")
    do prdRS.Execute()

    if (prdRS.Next())
    {
        set prddata = ##class(IRISELK.ProductionData.ProductionData).%New()
        set prddata.NameSpace = namespace
        set prddata.ProductionName = prdRS.Data("Production")
        set prddata.Status = prdRS.Data("Status")
        set prddata.StatusEnum = prdRS.Data("StatusEnum")

        if (prdRS.Data("LastStartTime") '= "")
        {
            set prddata.LastStartTime = prdRS.Data("LastStartTime")
        }

        if (prdRS.Data("LastStopTime") '= "")
        {
            set prddata.LastStopTime = prdRS.Data("LastStopTime")
        }

		return prddata
    }

	return ""
}

/// Get list of all Foundation namespaces
ClassMethod GetSupportedNamespaces() As %ListOfDataTypes
{
	set nslist = ##class(%ListOfDataTypes).%New()
	set nsRS = ##class(%ResultSet).%New("%SYS.Namespace:List")
	do nsRS.Execute()
	
	while (nsRS.Next())
	{
		set namespace = nsRS.Data("Nsp")

		if namespace = "HSLIB"
		{
			continue // Do not include HSLIB
		}

        if ..IsFoundationNameSpace(namespace)
		{
			do nslist.Insert(namespace)
		}
	}

	return nslist
}

/// Is this a Foundation namespace?
ClassMethod IsFoundationNameSpace(namespace As %String) As %Boolean
{
    new $NAMESPACE
    set $NAMESPACE = namespace

    // Check if the namespace supports productions
    return ##class(%Dictionary.CompiledClass).%ExistsId("Ens.Config.Production")
}

}
