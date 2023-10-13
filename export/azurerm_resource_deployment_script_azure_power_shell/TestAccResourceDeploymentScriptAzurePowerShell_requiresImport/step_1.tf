
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231013044152761181"
  location = "West Europe"
}


resource "azurerm_resource_deployment_script_azure_power_shell" "test" {
  name                = "acctest-rdsaps-231013044152761181"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  version             = "8.3"
  retention_interval  = "P1D"
  script_content      = <<EOF
		$output = 'Hello'
		Write-Output $output
		$DeploymentScriptOutputs = @{}
		$DeploymentScriptOutputs['text'] = $output
EOF
}


resource "azurerm_resource_deployment_script_azure_power_shell" "import" {
  name                = azurerm_resource_deployment_script_azure_power_shell.test.name
  resource_group_name = azurerm_resource_deployment_script_azure_power_shell.test.resource_group_name
  location            = azurerm_resource_deployment_script_azure_power_shell.test.location
  version             = azurerm_resource_deployment_script_azure_power_shell.test.version
  retention_interval  = azurerm_resource_deployment_script_azure_power_shell.test.retention_interval
  script_content      = azurerm_resource_deployment_script_azure_power_shell.test.script_content
}
