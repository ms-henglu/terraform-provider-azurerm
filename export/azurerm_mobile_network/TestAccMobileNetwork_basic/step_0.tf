
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230227033058049276"
  location = "eastus"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230227033058049276"
  resource_group_name = azurerm_resource_group.test.name
  location            = "eastus"
  mobile_country_code = "001"
  mobile_network_code = "01"
}
