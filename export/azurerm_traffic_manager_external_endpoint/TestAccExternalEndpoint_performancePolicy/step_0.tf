
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-221117231611371145"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-221117231611371145"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "acctest-tmp-221117231611371145"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "test" {
  name              = "acctestend-azure221117231611371145"
  target            = "www.example.com"
  weight            = 3
  profile_id        = azurerm_traffic_manager_profile.test.id
  endpoint_location = azurerm_resource_group.test.location
}
