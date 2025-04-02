/// Get Get Service or Hostname
Class IRISELK.Util.Hostname
{

/// Get the Service name for this POD
ClassMethod GetServiceOrHostName(Output namespace As %String) As %String
{
    set namespace = ..GetK8sNamespace()
    set hostname = $ZCONVERT(##class(%Library.Function).HostName(), "L")

    if (namespace '= "") && ($LENGTH(hostname, "-") > 2)  // we run on K8s and have a complicated hostname
    {
        return $PIECE(hostname, "-", 1, *-2)
    }
    
    return hostname
}

/// Get Kubernetes Namespace; return "" if not found
ClassMethod GetK8sNamespace() As %String
{
    set file = ##class(%File).%New("/var/run/secrets/kubernetes.io/serviceaccount/namespace")

    if $$$ISOK(file.Open("R"))
    {
        return file.ReadLine()
    }

    return ""
}

}
