
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034427981690"
  location = "West Europe"
}


resource "azurerm_network_function_azure_traffic_collector" "test" {
  name                = "acctest-nfatc-231016034427981690"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}
