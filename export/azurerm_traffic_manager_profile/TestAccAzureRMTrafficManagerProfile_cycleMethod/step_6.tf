

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-240119025954897254"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-240119025954897254"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctest-tmp-240119025954897254"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}
