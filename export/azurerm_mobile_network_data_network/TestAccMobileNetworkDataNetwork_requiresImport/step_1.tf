

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-230922061528246135"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-230922061528246135"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mndn-230922061528246135"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
}


resource "azurerm_mobile_network_data_network" "import" {
  name              = azurerm_mobile_network_data_network.test.name
  mobile_network_id = azurerm_mobile_network_data_network.test.mobile_network_id
  location          = azurerm_mobile_network_data_network.test.location
}
