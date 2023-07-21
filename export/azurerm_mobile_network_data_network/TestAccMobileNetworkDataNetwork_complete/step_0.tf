
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230721015600512993"
  location = "eastus"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230721015600512993"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mndn-230721015600512993"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
  description       = "my favourite data network"
  tags = {
    key = "value"
  }
}
