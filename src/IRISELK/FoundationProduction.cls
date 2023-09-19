Class IRISELK.FoundationProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="IRISELK.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="true">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="IRISELK.Audit.AuditMonitorService" Category="" ClassName="IRISELK.Audit.AuditMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
  <Item Name="IRISELK.EventLog.EventLogService" Category="" ClassName="IRISELK.EventLog.EventLogService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
  <Item Name="IRISELK.Header.HeaderMonitorService" Category="" ClassName="IRISELK.Header.HeaderMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
  <Item Name="IRISELK.BusinessOperation.LogstashOutbound" Category="" ClassName="IRISELK.BusinessOperation.LogstashOutbound" PoolSize="5" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="IRISELK.ProductionData.ProductionMonitorService" Category="" ClassName="IRISELK.ProductionData.ProductionMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
  <Item Name="IRISELK.System.SystemMonitorService" Category="" ClassName="IRISELK.System.SystemMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
  <Item Name="IRISELK.Task.TaskMonitorService" Category="" ClassName="IRISELK.Task.TaskMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
  <Item Name="IRISELK.License.LicenseMonitorService" Category="" ClassName="IRISELK.License.LicenseMonitorService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">60</Setting>
  </Item>
</Production>
}

}
