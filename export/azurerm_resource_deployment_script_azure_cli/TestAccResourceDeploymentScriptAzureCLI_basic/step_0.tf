
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231218072455217457"
  location = "West Europe"
}


resource "azurerm_resource_deployment_script_azure_cli" "test" {
  name                = "acctest-rdsac-231218072455217457"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  version             = "2.40.0"
  retention_interval  = "P1D"
  script_content      = <<EOF
            echo '{"name":{"displayName":"firstname lastname"}}' > $AZ_SCRIPTS_OUTPUT_PATH
  EOF
}
