
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-210830084554137619"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-210830084554137619"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctest-tmp-210830084554137619"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external210830084554137619"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
  priority            = 1
  custom_header {
    name  = "header"
    value = "www.bing.com"
  }
}

resource "azurerm_traffic_manager_endpoint" "testExternalNew" {
  name                = "acctestend-external210830084554137619-2"
  type                = "externalEndpoints"
  target              = "www.pluginsdk.io"
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
  priority            = 2
}
