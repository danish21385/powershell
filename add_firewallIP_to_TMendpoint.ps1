
#adding firewall public ip to traffic manager's endpoint

$ip = Get-AzPublicIpAddress -Name "newvmpipsarshar" -ResourceGroupName $rg
New-AzTrafficManagerEndpoint –Name vlstage-asr –ProfileName sarshardeletetm -ResourceGroupName $rg –Type AzureEndpoints -TargetResourceId $ip.Id –EndpointStatus Enabled
disable-AzTrafficManagerEndpoint -name "MyIpEndpoint" -profilename "sarshardeletetm" -ResourceGroupName $rg -type azureendpoints -force