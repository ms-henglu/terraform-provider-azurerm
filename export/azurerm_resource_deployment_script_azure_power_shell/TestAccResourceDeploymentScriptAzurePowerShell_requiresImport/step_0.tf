
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119025728755371"
  location = "West Europe"
}


resource "azurerm_resource_deployment_script_azure_power_shell" "test" {
  name                = "acctest-rdsaps-240119025728755371"
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
