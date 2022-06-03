
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220603005416405622"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220603005416405622"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-220603005416405622"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_traffic_manager_external_endpoint" "test" {
  name       = "acctestend-azure220603005416405622"
  target     = "www.example.com"
  weight     = 3
  profile_id = azurerm_traffic_manager_profile.test.id
}
