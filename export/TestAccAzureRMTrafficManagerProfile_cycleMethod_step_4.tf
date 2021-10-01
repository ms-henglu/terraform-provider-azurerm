

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211001021323091540"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211001021323091540"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Subnet"

  dns_config {
    relative_name = "acctest-tmp-211001021323091540"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}
