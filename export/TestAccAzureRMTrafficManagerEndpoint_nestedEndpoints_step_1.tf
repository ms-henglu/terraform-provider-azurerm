
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211015015235273851"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "acctesttmpparent211015015235273851"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctestparent211015015235273851"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild211015015235273851"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild211015015235273851"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "nested" {
  name                                  = "acctestend-parent211015015235273851"
  type                                  = "nestedEndpoints"
  target_resource_id                    = azurerm_traffic_manager_profile.child.id
  priority                              = 1
  profile_name                          = azurerm_traffic_manager_profile.parent.name
  resource_group_name                   = azurerm_resource_group.test.name
  min_child_endpoints                   = 5
  minimum_required_child_endpoints_ipv4 = 2
  minimum_required_child_endpoints_ipv6 = 2
}

resource "azurerm_traffic_manager_endpoint" "externalChild" {
  name                = "acctestend-child211015015235273851"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  priority            = 1
  profile_name        = azurerm_traffic_manager_profile.child.name
  resource_group_name = azurerm_resource_group.test.name
}
