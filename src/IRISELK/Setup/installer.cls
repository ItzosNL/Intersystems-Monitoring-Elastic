Include (%occInclude, %occErrors)

/// Installer for MONITORING Namespace with IRISELK package
Class IRISELK.Setup.installer
{

Parameter Namespace As String = "MONITORING";

Parameter PackageName As String = "IRISELK";

Parameter ProductionName As String = "IRISELK.FoundationProduction";

/// PrintNamespace
ClassMethod PrintNamespace(phase As %String) As %Status
{
	w phase,": namespace =",$NAMESPACE,!
	return $$$OK
}

/// PreInstall - creates the specified namespace if it doesn't exist
ClassMethod PreInstall(namespace As %String = {..#Namespace}) As %Status
{
	set sc = $$$OK

	if '..NamespaceExists(namespace)
	{
		set vars("Namespace") = namespace
		set sc = ..setup(.vars)

		if $$$ISERR(sc)
		{
			Do $System.Status.DisplayError(sc)
		}
	}

	zn namespace

	return sc
}

/// PostInstall - sets the specified production as AutoStart 
ClassMethod PostInstall(productionName As %String = {..#ProductionName}, namespace As %String = "") As %Status
{
	w !,"Starting Post Install:",!
	do ..CreateALLNamespace()
	do ..CreatePackageMappingToALL(namespace)
	do ..CreateDefaultSSLConfig()
	do ..CompileProduction(productionName, namespace)

	do ##class(IRISELK.BusinessOperation.Config).SetConfig()

	return $$$OK
}

/// Create package mappings for package in %All namespace
ClassMethod CreatePackageMappingToALL(namespace As %String = "", packagename As %String = {..#PackageName})
{
	New $NAMESPACE
	Set $NAMESPACE = "%SYS"

	if namespace = ""
	{
		set namespace = ..#Namespace _ "_CODE"
	}

	if ##Class(Config.MapPackages).Exists("%All", packagename, .objref)
	{
		if (objref.Database = namespace)
		{
			write "Mapping for package " _ packagename _ " from DB " _ objref.Database _ " already exists in %All Namespace",!
			return
		}

		set sc = ##Class(Config.MapPackages).Delete("%All", packagename)

		if $$$ISERR(sc)
		{
			write "Error while deleting exting Mapping for package " _ packagename _ " to %All Namespace: ",!
			do $System.Status.DisplayError(sc)
		}
		else
		{
			write "Deleted existing Mapping for package " _ packagename _ "from DB " _ objref.Database _ " in %All Namespace",!
		}
	}

	set props("Database") = namespace // Will need to be made more flexible...
	set sc = ##Class(Config.MapPackages).Create("%All", packagename, .props)

	if $$$ISERR(sc)
	{
		if ($System.Status.GetErrorCodes(sc) = $$$CPFMapAlreadyExists)
		{
			write "Mapping for package " _ packagename _ " already exists in %All Namespace",!
		}
		else
		{
			write "Error while creating Mapping for package " _ packagename _ " to %All Namespace: "
			do $System.Status.DisplayError(sc)
			write !
		}
	}
	else
	{
		write "Created Mapping for package " _ packagename _  " from DB " _ namespace _ " to %All Namespace",!
	}
}

/// Create %All Namespace for package mappings if it doesn't exist
ClassMethod NamespaceExists(namespace As %String) As %Boolean
{
	new $NAMESPACE
	set $NAMESPACE = "%SYS"

	return ##class(Config.Namespaces).Exists(namespace)
}

/// Create %All Namespace for package mappings if it doesn't exist
ClassMethod CreateALLNamespace()
{
	New $NAMESPACE
	Set $NAMESPACE = "%SYS"

	if '##class(Config.Namespaces).Exists("%All")
	{
		set properties("Globals") = "%DEFAULTDB"
		set sc = ##class(Config.Namespaces).Create("%All", .properties)

		if $$$ISERR(sc)
		{
			w "Error while creatin %All Namespace: "
			Do $System.Status.DisplayError(sc)
		}
		else
		{
				w "%ALL namespace created!",!
		}
	}
	else
	{
		w "%ALL namespace already exists",!
	}
}

/// Manifest Definition for PreInstall
XData Manifest [ XMLNamespace = INSTALLER ]
{
<Manifest>
	<Log Text="Creating Iris namespace ${Namespace}" Level="0"/>
	<Namespace Name="${Namespace}" Create="yes" Code="${Namespace}_CODE" Data="${Namespace}_DATA" Ensemble="1">
		<Configuration>
			<Database Name="${Namespace}_DATA" Dir="${MGRDIR}${Namespace}_DATA" Create="yes" Resource="%DB_${Namespace}"/>
			<Database Name="${Namespace}_CODE" Dir="${MGRDIR}${Namespace}_CODE" Create="yes" Resource="%DB_${Namespace}"/>
		</Configuration>
	</Namespace>
</Manifest>
}

ClassMethod CreateDefaultSSLConfig() As %Status
{
	Set sc = $$$OK
	New $NAMESPACE
	Set $NAMESPACE = "%SYS"
	Set name = "Default"
	If ##class(Security.SSLConfigs).Exists(name) = 0 {
		Set sc = ##class(Security.SSLConfigs).Create(name)
	}
	return sc
}

/// This is a method generator whose code is generated by XGL.
ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
 #; Let our XGL document generate code for this method.
 return ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "Manifest")
}

/// Making a production Auto-Start
ClassMethod CompileProduction(productionName As %String = {..#ProductionName}, namespace As %String = {..#Namespace}) As %Status
{
	New $NAMESPACE
	Set $NAMESPACE = namespace

	// In turns out we need to recompile the production in the target namespace...
	set sc = $System.OBJ.Compile(productionName, "ckd")

	if $$$ISERR(sc)
	{
		do $System.Status.DisplayError(sc)
	}

	return sc
}

/// Start production and make auto-start
ClassMethod AutoStartProduction(productionName As %String = {..#ProductionName}, namespace As %String = {..#Namespace}) As %Status
{
	new $NAMESPACE
	set $NAMESPACE = namespace
	set sc = $$$OK

	// Only start production of not already running
	if '##class(Ens.Director).IsProductionRunning()
	{
        write "Start Production ",productionName,": "
		set sc = ##class(Ens.Director).StartProduction(productionName)

		if $$$ISERR(sc)
		{
			write " failed: ",$System.Status.GetErrorText(sc)
			return sc
		}
	}

    write "Make sure Production ",productionName," autostarts: "
	set sc = ##class(Ens.Director).SetAutoStart(productionName)

	if $$$ISERR(sc)
	{
        write " failed: ",$System.Status.GetErrorText(sc)
	}

    write !

	return sc
}

/// Stop the production and remove auto-start
ClassMethod StopProduction(namespace As %String = {..#Namespace}) As %Status
{
	new $NAMESPACE
	set $NAMESPACE = namespace
	set sc = $$$OK

	// Only start production of not already running
	if '##class(Ens.Director).IsProductionRunning()
	{
        write "Stop Production for namespace ",namespace,": "
		set sc = ##class(Ens.Director).StopProduction()

		if $$$ISERR(sc)
		{
			write " failed: ",$System.Status.GetErrorText(sc)
			return sc
		}
	}

    write "Remove Autostart for namespace ",namespace,": "
	set sc = ##class(Ens.Director).SetAutoStart()

	if $$$ISERR(sc)
	{
        write " failed: ",$System.Status.GetErrorText(sc)
	}

    write !

	return sc
}

}
