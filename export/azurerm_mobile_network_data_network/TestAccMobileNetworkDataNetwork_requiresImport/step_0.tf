
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230721015600513142"
  location = "eastus"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230721015600513142"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mndn-230721015600513142"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
}
