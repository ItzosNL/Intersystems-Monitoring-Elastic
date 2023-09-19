/// Gather and send license information
Class IRISELK.License.LicenseMonitorService Extends Ens.BusinessService [ Language = objectscript ]
{

Parameter ADAPTER = "Ens.InboundAdapter";

/// Called every time the CallInterval expires
Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
    set req =  ..GetIRISLicenseInfo()

    do ..SendRequestAsync("IRISELK.BusinessOperation.LogstashOutbound", req)
 
    return $$$OK
}

/// Get IRIS License information from %SYS namespace
ClassMethod GetIRISLicenseInfo() As IRISELK.License.LicenseMonitorRequest
{
    set req = ##class(IRISELK.License.LicenseMonitorRequest).%New()
    set licensedata = ##class(IRISELK.License.LicenseData).%New()

    new $NAMESPACE
    set $NAMESPACE = "%SYS"

    set licensedata.LicenseInfo = ##class(%SYSTEM.License).KeyLicenseCapacity()
    set licensedata.ExpirationDate = $ZDATE(##class(%SYSTEM.License).KeyExpirationDate())
    set licensedata.DaysUntilExpire = $SYSTEM.SQL.DATEDIFF("dd", $NOW(), ##class(%SYSTEM.License).KeyExpirationDate())

    do req.LicenseData.Insert(licensedata)

    return req
}

}
