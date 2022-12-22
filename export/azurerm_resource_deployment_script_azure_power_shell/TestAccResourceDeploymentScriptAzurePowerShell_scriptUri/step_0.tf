
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221222035234760269"
  location = "West Europe"
}


resource "azurerm_resource_deployment_script_azure_power_shell" "test" {
  name                = "acctest-rdsaps-221222035234760269"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  version             = "8.3"
  retention_interval  = "P1D"
  command_line        = "-name \"John Dole\""
  primary_script_uri  = "https://raw.githubusercontent.com/Azure/azure-docs-json-samples/master/deployment-script/deploymentscript-helloworld.ps1"
}
