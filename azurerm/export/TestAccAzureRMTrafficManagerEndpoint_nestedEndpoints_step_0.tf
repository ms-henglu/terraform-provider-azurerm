
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220627132441319904"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "acctesttmpparent220627132441319904"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctestparent220627132441319904"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild220627132441319904"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild220627132441319904"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "nested" {
  name                = "acctestend-parent220627132441319904"
  type                = "nestedEndpoints"
  target_resource_id  = azurerm_traffic_manager_profile.child.id
  priority            = 1
  profile_name        = azurerm_traffic_manager_profile.parent.name
  resource_group_name = azurerm_resource_group.test.name
  min_child_endpoints = 1
}

resource "azurerm_traffic_manager_endpoint" "externalChild" {
  name                = "acctestend-child220627132441319904"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  priority            = 1
  profile_name        = azurerm_traffic_manager_profile.child.name
  resource_group_name = azurerm_resource_group.test.name
}
