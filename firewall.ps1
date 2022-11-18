$ErrorActionPreference = "stop"

$vnetname = 'TestingScriptDeleteVM-vnet-asr'
$rg = 'tragedy'
$location ="west US"
$fwsubnetname = 'AzureFirewallSubnet'
$fwprefix = '10.11.1.0/26'
$pip = '20.237.215.134'


#Create firewall subnet in existing vnet 

$vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg
Add-AzVirtualNetworkSubnetConfig -Name $fwsubnetname -AddressPrefix $fwprefix -VirtualNetwork $vnet
$vnet | Set-AzVirtualNetwork

#Creating firewall
$Azfw = New-AzFirewall -Name vlstage-firewall -ResourceGroupName $RG -Location $Location -VirtualNetwork $vnetname -PublicIpaddress $pip

#Adding outbound application rule in firewall to allow all traffic

$Azfw = Get-AzFirewall -ResourceGroupName $rg
$apprule = New-AzFirewallApplicationRule -Name 'Allow-All' -Protocol "http:80","https:443" -TargetFqdn "*" -SourceAddress '*' 
$appruleCollection = New-AzFirewallApplicationRuleCollection -Name 'AppRuleCollection' -Priority 100 -Rule $apprule -ActionType "Allow"
$Azfw.ApplicationRuleCollections = $appruleCollection
Set-AzFirewall -AzureFirewall $Azfw

#Adding outbound network rule in firewall to allow all traffic

 $Azfw = Get-AzFirewall -ResourceGroupName $rg
 $netrule = New-AzFirewallNetworkRule -Name 'Allow-All' -Protocol TCP -SourceAddress '*' -DestinationAddress '*' -DestinationPort "*"
 $netrulecollection = New-AzFirewallNetworkRuleCollection -Name 'NetRuleCollection' -Priority 100 -Rule $netrule -ActionType "Allow"
 $Azfw.NetworkRuleCollections = $netrulecollection
 Set-AzFirewall -AzureFirewall $Azfw

#Adding inbount NAT rule

$Azfw = Get-AzFirewall -ResourceGroupName $rg
$natrule1 = New-AzFirewallNatRule -Name "http" -Protocol "TCP" -SourceAddress "*" -DestinationAddress $pip -DestinationPort "80" -TranslatedAddress "10.0.0.2" -TranslatedPort "80"
$natrule2 = New-AzFirewallNatRule -Name "https" -Protocol "TCP" -SourceAddress "*" -DestinationAddress $pip -DestinationPort "443" -TranslatedAddress "10.0.0.2" -TranslatedPort "443"
$natruleCollection = New-AzFirewallNatRuleCollection -Name "NatRuleCollection" -Priority 1000 -Rule $natrule1, $natrule2
$Azfw.NatRuleCollections = $natrulecollection
Set-AzFirewall -AzureFirewall $Azfw

#Creating user defined route and attach it to default subnet

$Route = New-AzRouteConfig -Name "defaultroute" -AddressPrefix 0.0.0.0/0 -NextHopType VirtualAppliance -NextHopIpAddress 10.10.10.1
New-AzRouteTable -Name "RouteTable01" -ResourceGroupName $rg -Location $location -Route $Route
$rt = Get-AzRouteTable -ResourceGroupName $rg -Name "RouteTable01"
$vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg
Set-AzVirtualNetworkSubnetConfig  -VirtualNetwork $vnet -Name 'default' -AddressPrefix 10.11.0.0/24 -RouteTable $rt 
Set-AzVirtualNetwork -VirtualNetwork $vnet