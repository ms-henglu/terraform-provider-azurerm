

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211015015235273618"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211015015235273618"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "acctest-tmp-211015015235273618"
    ttl           = 0
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}
