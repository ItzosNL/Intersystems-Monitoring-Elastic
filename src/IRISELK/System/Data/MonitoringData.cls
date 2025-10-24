Class IRISELK.System.Data.MonitoringData Extends (IRISELK.Messages.LogstashRequest, %SerialObject, %XML.Adaptor)
{

Property CacheEfficiency As %Double;

Property CpuUsage As %Double;

Property CspActivity As %Double;

Property CspActualConnections As %Double;

Property CspGatewayLatency As %Double;

Property CspInUseConnections As %Double;

Property CspPrivateConnections As %Double;

Property CspSessions As %Double;

Property DiskPercentFull As array Of %DataType;

Property EcpConn As %Double;

Property EcpConnMax As %Double;

Property EcpConnections As %Double;

Property EcpLatency As %Double;

Property EcpsConn As %Double;

Property EcpsConnMax As %Double;

Property PhysMemPercentUsed As %Double;

Property PhysReadsPerSec As %Double;

Property PhysWritesPerSec As %Double;

Property ProcessCount As %Double;

Property RtnASeizePerSec As %Double;

Property RtnCallLocalPerSec As %Double;

Property SystemAlerts As %Double;

Property SystemAlertsLog As %Double;

Property SystemAlertsNew As %Double;

Property SystemState As %Double;

Storage Default
{
<Data name="MonitoringDataDefaultData">
<Subscript>"MonitoringData"</Subscript>
<Value name="1">
<Value>CacheEfficiency</Value>
</Value>
<Value name="2">
<Value>CpuPct</Value>
</Value>
<Value name="3">
<Value>CpuUsage</Value>
</Value>
<Value name="4">
<Value>CspActivity</Value>
</Value>
<Value name="5">
<Value>CspActualConnections</Value>
</Value>
<Value name="6">
<Value>CspGatewayLatency</Value>
</Value>
<Value name="7">
<Value>CspInUseConnections</Value>
</Value>
<Value name="8">
<Value>CspPrivateConnections</Value>
</Value>
<Value name="9">
<Value>CspSessions</Value>
</Value>
<Value name="10">
<Value>DbExpansionSizeMb</Value>
</Value>
<Value name="11">
<Value>DbFreeSpace</Value>
</Value>
<Value name="12">
<Value>DbLatency</Value>
</Value>
<Value name="13">
<Value>DbMaxSizeMb</Value>
</Value>
<Value name="14">
<Value>DbSizeMb</Value>
</Value>
<Value name="15">
<Value>DirectorySpace</Value>
</Value>
<Value name="16">
<Value>DiskPercentFull</Value>
</Value>
<Value name="17">
<Value>EcpConn</Value>
</Value>
<Value name="18">
<Value>EcpConnMax</Value>
</Value>
<Value name="19">
<Value>EcpConnections</Value>
</Value>
<Value name="20">
<Value>EcpLatency</Value>
</Value>
<Value name="21">
<Value>EcpsConn</Value>
</Value>
<Value name="22">
<Value>EcpsConnMax</Value>
</Value>
<Value name="23">
<Value>GloASeizePerSec</Value>
</Value>
<Value name="24">
<Value>GloNSeizePerSec</Value>
</Value>
<Value name="25">
<Value>GloRefPerSec</Value>
</Value>
<Value name="26">
<Value>GloRefRemPerSec</Value>
</Value>
<Value name="27">
<Value>GloSeizePerSec</Value>
</Value>
<Value name="28">
<Value>GloUpdatePerSec</Value>
</Value>
<Value name="29">
<Value>GloUpdateRemPerSec</Value>
</Value>
<Value name="30">
<Value>JrnBlockPerSec</Value>
</Value>
<Value name="31">
<Value>JrnEntryPerSec</Value>
</Value>
<Value name="32">
<Value>JrnFreeSpace</Value>
</Value>
<Value name="33">
<Value>JrnSize</Value>
</Value>
<Value name="34">
<Value>LogReadsPerSec</Value>
</Value>
<Value name="35">
<Value>ObjASeizePerSec</Value>
</Value>
<Value name="36">
<Value>ObjDelPerSec</Value>
</Value>
<Value name="37">
<Value>ObjHitPerSec</Value>
</Value>
<Value name="38">
<Value>ObjLoadPerSec</Value>
</Value>
<Value name="39">
<Value>ObjMissPerSec</Value>
</Value>
<Value name="40">
<Value>ObjNewPerSec</Value>
</Value>
<Value name="41">
<Value>ObjSeizePerSec</Value>
</Value>
<Value name="42">
<Value>PageSpacePercentUsed</Value>
</Value>
<Value name="43">
<Value>PhysMemPercentUsed</Value>
</Value>
<Value name="44">
<Value>PhysReadsPerSec</Value>
</Value>
<Value name="45">
<Value>PhysWritesPerSec</Value>
</Value>
<Value name="46">
<Value>ProcessCount</Value>
</Value>
<Value name="47">
<Value>RtnASeizePerSec</Value>
</Value>
<Value name="48">
<Value>RtnCallLocalPerSec</Value>
</Value>
<Value name="49">
<Value>RtnCallMissPerSec</Value>
</Value>
<Value name="50">
<Value>RtnCallRemotePerSec</Value>
</Value>
<Value name="51">
<Value>RtnLoadPerSec</Value>
</Value>
<Value name="52">
<Value>RtnLoadRemPerSec</Value>
</Value>
<Value name="53">
<Value>RtnSeizePerSec</Value>
</Value>
<Value name="54">
<Value>SamGetDbSensorsSeconds</Value>
</Value>
<Value name="55">
<Value>SamGetInteropSensorsSeconds</Value>
</Value>
<Value name="56">
<Value>SamGetJrnSensorsSeconds</Value>
</Value>
<Value name="57">
<Value>SamGetSqlSensorsSeconds</Value>
</Value>
<Value name="58">
<Value>SamGetWqmSensorsSeconds</Value>
</Value>
<Value name="59">
<Value>SmhAvailable</Value>
</Value>
<Value name="60">
<Value>SmhPercentFull</Value>
</Value>
<Value name="61">
<Value>SmhTotal</Value>
</Value>
<Value name="62">
<Value>SmhTotalPercentFull</Value>
</Value>
<Value name="63">
<Value>SmhUsed</Value>
</Value>
<Value name="64">
<Value>SqlQueriesAvgRuntime</Value>
</Value>
<Value name="65">
<Value>SqlQueriesAvgRuntimeStdDev</Value>
</Value>
<Value name="66">
<Value>SqlQueriesPerSecond</Value>
</Value>
<Value name="67">
<Value>SqlRowCountPerSecond</Value>
</Value>
<Value name="68">
<Value>SystemAlerts</Value>
</Value>
<Value name="69">
<Value>SystemAlertsLog</Value>
</Value>
<Value name="70">
<Value>SystemAlertsNew</Value>
</Value>
<Value name="71">
<Value>SystemState</Value>
</Value>
<Value name="72">
<Value>TransOpenCount</Value>
</Value>
<Value name="73">
<Value>TransOpenSecs</Value>
</Value>
<Value name="74">
<Value>TransOpenSecsMax</Value>
</Value>
<Value name="75">
<Value>WdBufferRedirty</Value>
</Value>
<Value name="76">
<Value>WdBufferWrite</Value>
</Value>
<Value name="77">
<Value>WdCycleTime</Value>
</Value>
<Value name="78">
<Value>WdProcInGlobal</Value>
</Value>
<Value name="79">
<Value>WdSizeWrite</Value>
</Value>
<Value name="80">
<Value>WdSleep</Value>
</Value>
<Value name="81">
<Value>WdTempQueue</Value>
</Value>
<Value name="82">
<Value>WdTempWrite</Value>
</Value>
<Value name="83">
<Value>WdWriteTime</Value>
</Value>
<Value name="84">
<Value>WdwijTime</Value>
</Value>
<Value name="85">
<Value>WijWritesPerSec</Value>
</Value>
<Value name="86">
<Value>WqmActiveWorkerJobs</Value>
</Value>
<Value name="87">
<Value>WqmCommandsPerSec</Value>
</Value>
<Value name="88">
<Value>WqmGlobalsPerSec</Value>
</Value>
<Value name="89">
<Value>WqmMaxActiveWorkerJobs</Value>
</Value>
<Value name="90">
<Value>WqmMaxWorkQueueDepth</Value>
</Value>
<Value name="91">
<Value>WqmWaitingWorkerJobs</Value>
</Value>
</Data>
<DefaultData>MonitoringDataDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
