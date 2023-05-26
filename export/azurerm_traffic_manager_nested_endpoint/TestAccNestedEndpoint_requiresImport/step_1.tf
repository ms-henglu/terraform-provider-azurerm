

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230526090033832937"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "parent" {
  name                   = "acctest-TMP-230526090033832937"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-230526090033832937"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_profile" "child" {
  name                   = "acctesttmpchild230526090033832937"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctesttmpchild230526090033832937"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_traffic_manager_nested_endpoint" "test" {
  name                    = "acctestend-parent230526090033832937"
  target_resource_id      = azurerm_traffic_manager_profile.child.id
  profile_id              = azurerm_traffic_manager_profile.parent.id
  minimum_child_endpoints = 5
  weight                  = 3
}


resource "azurerm_traffic_manager_nested_endpoint" "import" {
  name                    = azurerm_traffic_manager_nested_endpoint.test.name
  target_resource_id      = azurerm_traffic_manager_nested_endpoint.test.target_resource_id
  profile_id              = azurerm_traffic_manager_nested_endpoint.test.profile_id
  minimum_child_endpoints = azurerm_traffic_manager_nested_endpoint.test.minimum_child_endpoints
  weight                  = azurerm_traffic_manager_nested_endpoint.test.weight
}
