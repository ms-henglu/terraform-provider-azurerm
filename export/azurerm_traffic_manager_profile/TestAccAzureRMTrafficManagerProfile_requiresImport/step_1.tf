


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-231016034905104069"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-231016034905104069"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "acctest-tmp-231016034905104069"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_traffic_manager_profile" "import" {
  name                   = azurerm_traffic_manager_profile.test.name
  resource_group_name    = azurerm_traffic_manager_profile.test.resource_group_name
  traffic_routing_method = azurerm_traffic_manager_profile.test.traffic_routing_method

  dns_config {
    relative_name = "acctest-tmp-231016034905104069"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}
