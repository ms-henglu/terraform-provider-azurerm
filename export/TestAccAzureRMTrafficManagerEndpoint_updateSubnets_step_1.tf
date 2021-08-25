
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-210825045334076004"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-210825045334076004"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Subnet"

  dns_config {
    relative_name = "acctest-tmp-210825045334076004"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external210825045334076004"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_traffic_manager_endpoint" "testExternalNew" {
  name                = "acctestend-external210825045334076004-2"
  type                = "externalEndpoints"
  target              = "www.pluginsdk.io"
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
  subnet {
    first = "12.34.56.78"
    last  = "12.34.56.78"
  }
}
