

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220415031222690737"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220415031222690737"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "MultiValue"

  dns_config {
    relative_name = "acctest-tmp-220415031222690737"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 10
    timeout_in_seconds           = 8
    tolerated_number_of_failures = 3
  }
}
