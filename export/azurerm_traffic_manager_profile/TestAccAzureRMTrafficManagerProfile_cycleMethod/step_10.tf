

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230227033536363452"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-230227033536363452"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "MultiValue"
  max_return             = 8

  dns_config {
    relative_name = "acctest-tmp-230227033536363452"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}
