
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230915024341798491"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-230915024341798491"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Subnet"

  dns_config {
    relative_name = "acctest-tmp-230915024341798491"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild230915024341798491"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild230915024341798491"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_nested_endpoint" "test" {
  name                    = "acctestend-parent230915024341798491"
  target_resource_id      = azurerm_traffic_manager_profile.child.id
  profile_id              = azurerm_traffic_manager_profile.test.id
  minimum_child_endpoints = 5
  weight                  = 3

  subnet {
    first = "1.2.3.0"
    scope = "24"
  }
  subnet {
    first = "11.12.13.14"
    last  = "11.12.13.14"
  }
}
