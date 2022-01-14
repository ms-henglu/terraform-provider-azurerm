
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220114064744956760"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "acctesttmpparent220114064744956760"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctestparent220114064744956760"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild220114064744956760"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild220114064744956760"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "nested" {
  name                                  = "acctestend-parent220114064744956760"
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
  name                = "acctestend-child220114064744956760"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  priority            = 1
  profile_name        = azurerm_traffic_manager_profile.child.name
  resource_group_name = azurerm_resource_group.test.name
}
