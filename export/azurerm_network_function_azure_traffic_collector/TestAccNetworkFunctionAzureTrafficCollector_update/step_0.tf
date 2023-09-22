
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230922061635067053"
  location = "West Europe"
}


resource "azurerm_network_function_azure_traffic_collector" "test" {
  name                = "acctest-nfatc-230922061635067053"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  tags = {
    key = "value"
  }
}
