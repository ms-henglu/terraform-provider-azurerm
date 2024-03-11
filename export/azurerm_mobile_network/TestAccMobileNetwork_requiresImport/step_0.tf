
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-240311032609343864"
  location = "West Europe"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-240311032609343864"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}
