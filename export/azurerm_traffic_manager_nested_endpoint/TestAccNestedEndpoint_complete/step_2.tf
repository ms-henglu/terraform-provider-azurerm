
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230421023052331083"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "acctest-TMP-230421023052331083"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-230421023052331083"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild230421023052331083"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild230421023052331083"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_traffic_manager_nested_endpoint" "test" {
  name                                  = "acctestend-parent230421023052331083"
  target_resource_id                    = azurerm_traffic_manager_profile.child.id
  priority                              = 3
  profile_id                            = azurerm_traffic_manager_profile.parent.id
  weight                                = 5
  minimum_child_endpoints               = 9
  minimum_required_child_endpoints_ipv4 = 2
  minimum_required_child_endpoints_ipv6 = 2
  endpoint_location                     = azurerm_resource_group.test.location

  geo_mappings = ["WORLD"]
}
