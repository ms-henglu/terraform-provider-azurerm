
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230512011047402833"
  location = "eastus"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230512011047402833"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}
