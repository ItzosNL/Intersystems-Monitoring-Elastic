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
ClassMethod GetK8sNamespace() As %String [ Language = python ]
{
    try:
        return open("/var/run/secrets/kubernetes.io/serviceaccount/namespace").read()
    except:
        return ""
        pass
}

/// Get the service name for the pod
/// Not used right now
ClassMethod PyGetServiceNameForPod(namespace As %String, podname As %String) As %String [ Language = python ]
{
    try:
        from kubernetes import client, config

        #; Should work, but needs API server to accept Service credentials
        #; config.load_incluster_config() 
        #; Temporarily use our own credentials
        config.load_kube_config(config_file='/home/irisowner/.kube/config')
        kube_client = client.CoreV1Api()

        pods = kube_client.list_namespaced_pod(namespace).items
        for pod in pods:
            if pod.metadata.name == podname:
                #; print(pod.metadata.namespace, pod.metadata.name, pod.status)
                #; print("%s\t%s\t%s" % (pod.status.pod_ip, pod.metadata.namespace, pod.metadata.name))
                #; for cs in :
                return pod.status.container_statuses[0].name

    except:
        pass

    return ""
}

}
