

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-routingintent-240119025527749547"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestVWAN-240119025527749547"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestVHUB-240119025527749547"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}

resource "azurerm_firewall" "test" {
  name                = "acctestFW-240119025527749547"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.test.id
    public_ip_count = 1
  }
}


resource "azurerm_virtual_hub_routing_intent" "test" {
  name           = "acctest-routingintent-240119025527749547"
  virtual_hub_id = azurerm_virtual_hub.test.id

  routing_policy {
    name         = "InternetTrafficPolicy"
    destinations = ["Internet"]
    next_hop     = azurerm_firewall.test.id
  }
}
