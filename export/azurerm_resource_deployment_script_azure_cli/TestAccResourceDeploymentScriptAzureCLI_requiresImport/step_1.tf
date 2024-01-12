
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112225157599248"
  location = "West Europe"
}


resource "azurerm_resource_deployment_script_azure_cli" "test" {
  name                = "acctest-rdsac-240112225157599248"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  version             = "2.40.0"
  retention_interval  = "P1D"
  script_content      = <<EOF
            echo '{"name":{"displayName":"firstname lastname"}}' > $AZ_SCRIPTS_OUTPUT_PATH
  EOF
}


resource "azurerm_resource_deployment_script_azure_cli" "import" {
  name                = azurerm_resource_deployment_script_azure_cli.test.name
  resource_group_name = azurerm_resource_deployment_script_azure_cli.test.resource_group_name
  location            = azurerm_resource_deployment_script_azure_cli.test.location
  version             = azurerm_resource_deployment_script_azure_cli.test.version
  retention_interval  = azurerm_resource_deployment_script_azure_cli.test.retention_interval
  script_content      = azurerm_resource_deployment_script_azure_cli.test.script_content
}
