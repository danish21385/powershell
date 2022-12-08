
$rg = "tragedy"
$lbname = "vl-stage-asr"
$backendPoolName = "backendpool1"
$vmnic1 = "vmtestscriptdelet54"

$mylb = Get-AzLoadBalancer -Name $lbname -ResourceGroupName $rg
$bep = Get-AzLoadBalancerBackendAddressPoolConfig -Name $backendPoolName -LoadBalancer $mylb
$nic1 = Get-AzNetworkInterface -ResourceGroupName $rg -Name $vmnic1
$nic1.IpConfigurations[0].LoadBalancerBackendAddressPools = $bep
$nic1 | Set-AzNetworkInterface