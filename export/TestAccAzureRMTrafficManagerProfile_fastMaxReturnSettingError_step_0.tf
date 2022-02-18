

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220218071409925545"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220218071409925545"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "MultiValue"

  dns_config {
    relative_name = "acctest-tmp-220218071409925545"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "https"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 10
    timeout_in_seconds           = 8
    tolerated_number_of_failures = 3
  }
}
