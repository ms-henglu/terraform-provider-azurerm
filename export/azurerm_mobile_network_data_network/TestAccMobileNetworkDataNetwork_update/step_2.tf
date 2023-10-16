
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-231016034321690645"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-231016034321690645"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_data_network" "test" {
  name              = "acctest-mndn-231016034321690645"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_resource_group.test.location
  description       = "my favourite data network 2"
  tags = {
    key = "updated"
  }

}
