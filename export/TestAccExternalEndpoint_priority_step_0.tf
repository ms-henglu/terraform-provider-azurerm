
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220916012132690324"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220916012132690324"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctest-tmp-220916012132690324"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "test" {
  name       = "acctestend-azure220916012132690324"
  target     = "www.example.com"
  profile_id = azurerm_traffic_manager_profile.test.id
}
