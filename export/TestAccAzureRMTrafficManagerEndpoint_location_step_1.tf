
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211015014929648014"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctesttmpparent211015014929648014"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "acctestparent211015014929648014"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "test" {
  name                = "acctestend-external211015014929648014"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  endpoint_location   = azurerm_resource_group.test.location
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}
