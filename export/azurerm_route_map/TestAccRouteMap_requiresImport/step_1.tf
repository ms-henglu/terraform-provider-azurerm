


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-rm-230915023921355537"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-230915023921355537"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestvhub-230915023921355537"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}


resource "azurerm_route_map" "test" {
  name           = "acctestrm-ssocm"
  virtual_hub_id = azurerm_virtual_hub.test.id
}


resource "azurerm_route_map" "import" {
  name           = azurerm_route_map.test.name
  virtual_hub_id = azurerm_route_map.test.virtual_hub_id
}
