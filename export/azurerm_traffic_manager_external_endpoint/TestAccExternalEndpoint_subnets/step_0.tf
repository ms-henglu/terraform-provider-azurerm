
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-221111014400803587"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-221111014400803587"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Subnet"

  dns_config {
    relative_name = "acctest-tmp-221111014400803587"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "test" {
  name       = "acctestend-azure221111014400803587"
  target     = "www.example.com"
  weight     = 5
  profile_id = azurerm_traffic_manager_profile.test.id

  subnet {
    first = "1.2.3.0"
    scope = "24"
  }
  subnet {
    first = "11.12.13.14"
    last  = "11.12.13.14"
  }
}
