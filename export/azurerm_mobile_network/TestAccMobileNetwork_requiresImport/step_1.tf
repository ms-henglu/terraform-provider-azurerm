

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-240105061150594801"
  location = "West Europe"
}


resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-240105061150594801"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network" "import" {
  name                = azurerm_mobile_network.test.name
  resource_group_name = azurerm_mobile_network.test.resource_group_name
  location            = azurerm_mobile_network.test.location
  mobile_country_code = azurerm_mobile_network.test.mobile_country_code
  mobile_network_code = azurerm_mobile_network.test.mobile_network_code
}
