

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-231020041451025696"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-231020041451025696"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mndn-231020041451025696"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
}


resource "azurerm_mobile_network_data_network" "import" {
  name              = azurerm_mobile_network_data_network.test.name
  mobile_network_id = azurerm_mobile_network_data_network.test.mobile_network_id
  location          = azurerm_mobile_network_data_network.test.location
}
