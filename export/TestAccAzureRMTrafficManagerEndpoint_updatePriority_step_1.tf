
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211015014929646439"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211015014929646439"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctest-tmp-211015014929646439"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external211015014929646439"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  priority            = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_traffic_manager_endpoint" "testExternalNew" {
  name                = "acctestend-external211015014929646439-2"
  type                = "externalEndpoints"
  target              = "www.pluginsdk.io"
  priority            = 2
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}
