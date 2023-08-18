
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230818024521293524"
  location = "West Europe"
}


resource "azurerm_network_function_azure_traffic_collector" "test" {
  name                = "acctest-nfatc-230818024521293524"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  tags = {
    key = "value"
  }
}
