

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-221221204935599236"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-221221204935599236"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "MultiValue"
  max_return             = 8

  dns_config {
    relative_name = "acctest-tmp-221221204935599236"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}
