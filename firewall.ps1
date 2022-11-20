$ErrorActionPreference = "stop"
$WhatIfPreference = $true

$vnetname = 'TestingScriptDeleteVM-vnet-asr'
$rg = 'tragedy'
$location ="westUS"

$apprule = New-AzFirewallApplicationRule -Name 'Allow-All' -Protocol "http:80","https:443" -TargetFqdn "*" -SourceAddress '*' 
$appruleCollection = New-AzFirewallApplicationRuleCollection -Name 'AppRuleCollection' -Priority 100 -Rule $apprule -ActionType "Allow"

$netrule = New-AzFirewallNetworkRule -Name 'Allow-All' -Protocol TCP -SourceAddress '*' -DestinationAddress '*' -DestinationPort "*"
$netrulecollection = New-AzFirewallNetworkRuleCollection -Name 'NetRuleCollection' -Priority 100 -Rule $netrule -ActionType "Allow"

$natrule1 = New-AzFirewallNatRule -Name "http" -Protocol "TCP" -SourceAddress "*" -DestinationAddress 20.237.215.120 -DestinationPort "80" -TranslatedAddress "10.0.0.2" -TranslatedPort "80"
$natrule2 = New-AzFirewallNatRule -Name "https" -Protocol "TCP" -SourceAddress "*" -DestinationAddress 20.237.215.120 -DestinationPort "443" -TranslatedAddress "10.0.0.2" -TranslatedPort "443"
$natruleCollection = New-AzFirewallNatRuleCollection -Name "NatRuleCollection" -Priority 1000 -Rule $natrule1, $natrule2

#Creating firewall 

$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name "TestingScriptDeleteVM-vnet-asr"
$pip = Get-AzPublicIpAddress -ResourceGroupName $rg -Name "newvmpipsarshar"
New-AzFirewall -Name "vlstage-fw" -ResourceGroupName $rg -Location westUS -VirtualNetwork $vnet -PublicIpAddress $pip -ApplicationRuleCollection $appruleCollection -NetworkRuleCollection $netrulecollection -NatRuleCollection $natruleCollection