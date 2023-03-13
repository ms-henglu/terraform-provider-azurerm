

provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230313022031214376"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-230313022031214376"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-230313022031214376"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_traffic_manager_external_endpoint" "test" {
  name       = "acctestend-azure230313022031214376"
  target     = "www.example.com"
  weight     = 3
  profile_id = azurerm_traffic_manager_profile.test.id
}


resource "azurerm_traffic_manager_external_endpoint" "import" {
  name       = azurerm_traffic_manager_external_endpoint.test.name
  target     = azurerm_traffic_manager_external_endpoint.test.target
  weight     = azurerm_traffic_manager_external_endpoint.test.weight
  profile_id = azurerm_traffic_manager_external_endpoint.test.profile_id
}
