

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-express-230106034829538829"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-VWAN-230106034829538829"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHUB-230106034829538829"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}


resource "azurerm_express_route_gateway" "test" {
  name                = "acctestER-gateway-230106034829538829"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_hub_id      = azurerm_virtual_hub.test.id
  scale_units         = 1
}
