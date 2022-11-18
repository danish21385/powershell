$ErrorActionPreference = "stop"

$vnetname = 'TestingScriptDeleteVM-vnet-asr'
$rg = 'tragedy'
$location ="west US"


$vnet = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $rg
$subnet = Get-AzVirtualNetworkSubnetConfig  -name 'default' -VirtualNetwork $vnet

#Create FrontEndIPConfig and add the public ip to it.
  $frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name 'feip' `
  -Subnet $subnet

#Create a backendAddress pool to add the virtual machines.
  $backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name 'backendpool1'

#Create the load balancer with defined variable above.
  $lb = New-AzLoadBalancer `
  -ResourceGroupName $rg `
  -Name 'darpa' `
  -Location $location `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool

#Create Load balancer Probe Config for Port 80 & 443
  Add-AzLoadBalancerProbeConfig `
  -Name "Port_80" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 5 `
  -ProbeCount 2

  Add-AzLoadBalancerProbeConfig `
  -Name "Port_443" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 443 `
  -IntervalInSeconds 5 `
  -ProbeCount 2

  Set-AzLoadBalancer -LoadBalancer $lb

  $probe80 = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name "Port_80"
  $probe443 = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name "Port_443"


# Set the Azure Load Balancer Rule Confguration for Port 80
  $lb | Add-AzLoadBalancerRuleConfig -Name "HTTP" -FrontendIPConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $backendPool -Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -Probe $probe80 -IdleTimeoutInMinutes 4
  $lb | Set-AzLoadBalancer

# Set the Azure Load Balancer Rule Configuration for Port 443
  $lb | Add-AzLoadBalancerRuleConfig -Name "HTTPS" -FrontendIPConfiguration $lb.FrontendIpConfigurations[0] -BackendAddressPool $backendPool -Protocol "Tcp" -FrontendPort 443 -BackendPort 443 -Probe $probe443 -IdleTimeoutInMinutes 4
  $lb | Set-AzLoadBalancer