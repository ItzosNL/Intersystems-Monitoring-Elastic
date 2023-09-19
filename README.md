## InterSystems-Monitoring
This repository provides a Production which collects information from the relevant Ensemble namespaces and send status update to Logstash, so that you can monitor your InterSystems Productions from [Kibana Discover](https://www.elastic.co/guide/en/kibana/current/discover.html)


## Event Sources - What information is transmitted to logstash
The following information is being transmitted to logstash:
1. Audit records from %SYS.Audit - Incremental
2. License info from %SYSTEM.License (KeyLicenseCapacity and KeyExpirationDate)
3. Prometheus Metrics from SYS.Monitor.SAM.Sensors
4. Task history from %SYS_Task.History - Incremental

The following information is being transmitted to logstash from each Ensemble namespace:
1. Production Name and Status
2. Message headers from Ens.MessageHeader - Incremental
3. Eventlog records from Ens_Util.Log - Incremental

## Basic Structure and Working
The InterSystems-Monitoring package provides a foundation production named **IRISELK.FoundationProduction**.
This contains:
  - A Business service for each of the 7 event sources mentioned above, which by default all transmit data once every minute.
  - For each type of information that is sent incremental, a lastkey value is persisted to allow sending only new data.
  - All Services send the collected data to Logstah via the Business Operation named IRISELK.BusinessOperation.LogstashOutbound

The package has a post-install step that configures IRISELK.FoundationProduction to run and autostart in the designated Monitoring namespace

## Seting up InterSystems-Monitoring
InterSystems-Monitoring can be installed from package intersystems-monitoring using InterSystems Package Manager (ZPM).

Before that, make sure that you have a new namespace where you run the Monitoring production, which we usually call "MONITORING"

You might use method **PreInstall()** in class **IRISELK.Setup.installer**, like:

`set sc = ##class(IRISELK.Setup.installer).PreInstall()`

This will create the "MONITORING" namespace with seperate databases for Code and Data, so that a package mapping can be created for only the Code database to the %All namespace

Then, switch to the newly created namespace:

`zn "MONITORING"`

and install the Intersystems-Monitoring package:

`ZPM "install intersystems-monitoring"`

This will:
- Load the **IRISELK** Package
- Call **PostInstall** method of class **IRISELK.Setup.installer**, which will:
  - Create the %All namespace if it doesn't exists yet
  - Create a packagemapping for the IRISELK package from the Code-database of your namespace to the %All namespace.
    This is needed so that code can be called from all Ensemble-enabled namespaces
  - Create the SSL Configuration named "Default" as used by the Logstash sender if it doesn't exist yet
  - Sets the config based on the assumption that there is a json configuration file in location "/usr/irissys/mgr/config.json"
    You can override that by calling the **SetConfig** method on class **IRISELK.BusinessOperation.Config** with the path of your config file:
	
      `do ##class(IRISELK.BusinessOperation.Config).SetConfig("your config json location")`

  - Starts the production and sets it to Autostart. 

Once installed, you'll see 

![Production screenshot](Productionscreenshot.png)

## Sample Configuration file
This is a sample configuration file for InterSystems-Monitoring

{

    "stage": "dev|tst|acc|prd|other",

    "description": "Description of the business purpose of the instance",

    "customer": "Name of customer",

    "logstash-url": "url of the logstash instance, e.g. https://mydomain.com/logstash",

    "logstash-ssl-config":  "Default",

    "logstash-check-server-identity":  false,

    "logstash-proxy-address": "optional proxy address, e.g. http://my-proxy.com:8081"

}

Please note that the config.json is re-read each time before a transfer is made to Logstash.

## Standard header information sent to logstash
The Business Operation includes the following context information and includes it as HTTP headers:
| Header name           | Value                                                                                               |
| :-------------------- | :-------------------------------------------------------------------------------------------------- |
| server_name           | ##class(%Library.Function).HostName(), converted to lowercase. On Kubernetes, remove the pod-prefix |  
| k8s_namespace         | Kubernetes namespace - only when on Kubernetes                                                      |
| instance_name         | ##class(%SYS.System).GetInstanceName(), converted to lowercase.                                     |
| instance_product_type | "IRIS for Health" or "HealthConnect" or "IRIS"                                                      |
| instance_otap         | stage property from config.json, expected values: "dev", "tst", "acc", "prd", or "other"            |
| instance_description  | description property from config.json, should describe the business purpose of the instance         |
| server_client_name    | customer property from config.json, can be filled with the customer name                            |

## What you need to do in logstash to process your information
TBD

## Embedding InterSystems-Monitoring in another project
It is recommended that you include the setup of the IRISELK Monitoring production in your own installer, so that you it can be automatically deployed.
These are the steps needed to make that work:
1. Make sure that the Intersystems Package Manager (ZPM) is loaded. This is automatically the case for the Community Edition, but needs to be done as a separate step in your project if you run with a commercial license key
2. Install the intersystems-monitoring pqackage using ZPM

   `ZPM "install intersystems-monitoring"`

3. Make sure that you have a json config file that is properly configured for your instance

4. Call the **SetConfig** method on class **IRISELK.BusinessOperation.Config** to set 
	
    `do ##class(IRISELK.BusinessOperation.Config).SetConfig("your config json location")`

## Known issues
There are no known issues at this point in time

## Finally
Use or operation of this code is subject to acceptance of the license available in the code repository for this code.

