
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220715005000104713"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220715005000104713"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "acctest-tmp-220715005000104713"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "test" {
  name              = "acctestend-azure220715005000104713"
  target            = "www.example.com"
  weight            = 3
  profile_id        = azurerm_traffic_manager_profile.test.id
  endpoint_location = azurerm_resource_group.test.location
}
