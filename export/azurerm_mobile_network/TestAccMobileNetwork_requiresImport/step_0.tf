
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230825024924575960"
  location = "West Europe"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230825024924575960"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}
