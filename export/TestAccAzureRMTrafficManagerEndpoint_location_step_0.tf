
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211015015235274173"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctesttmpparent211015015235274173"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "acctestparent211015015235274173"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "test" {
  name                = "acctestend-external211015015235274173"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  endpoint_location   = azurerm_resource_group.test.location
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}
