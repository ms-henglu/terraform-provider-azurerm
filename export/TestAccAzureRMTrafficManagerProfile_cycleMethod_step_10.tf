

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211015015235270112"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211015015235270112"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "MultiValue"
  max_return             = 8

  dns_config {
    relative_name = "acctest-tmp-211015015235270112"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}
