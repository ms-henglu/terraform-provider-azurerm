
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211013072504593016"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "acctesttmpparent211013072504593016"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctestparent211013072504593016"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild211013072504593016"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild211013072504593016"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "nested" {
  name                = "acctestend-parent211013072504593016"
  type                = "nestedEndpoints"
  target_resource_id  = azurerm_traffic_manager_profile.child.id
  priority            = 1
  profile_name        = azurerm_traffic_manager_profile.parent.name
  resource_group_name = azurerm_resource_group.test.name
  min_child_endpoints = 5
}

resource "azurerm_traffic_manager_endpoint" "externalChild" {
  name                = "acctestend-child211013072504593016"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  priority            = 1
  profile_name        = azurerm_traffic_manager_profile.child.name
  resource_group_name = azurerm_resource_group.test.name
}
