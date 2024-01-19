

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-mn-240119025419078660"
  location = "West Europe"
}

resource "azurerm_mobile_network" "test" {
  name                = "acctest-mn-240119025419078660"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  mobile_country_code = "001"
  mobile_network_code = "01"
}


resource "azurerm_mobile_network_site" "test" {
  name              = "acctest-mns-240119025419078660"
  mobile_network_id = azurerm_mobile_network.test.id
  location          = azurerm_mobile_network.test.location
}


resource "azurerm_mobile_network_site" "import" {
  name              = azurerm_mobile_network_site.test.name
  mobile_network_id = azurerm_mobile_network_site.test.mobile_network_id
  location          = azurerm_mobile_network_site.test.location
}
