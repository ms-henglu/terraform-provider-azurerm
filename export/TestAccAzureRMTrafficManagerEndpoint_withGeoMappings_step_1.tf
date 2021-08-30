
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-210830084554139713"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-210830084554139713"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "acctest-tmp-210830084554139713"
    ttl           = 100
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_traffic_manager_endpoint" "test" {
  name                = "example.com"
  resource_group_name = azurerm_resource_group.test.name
  profile_name        = azurerm_traffic_manager_profile.test.name
  target              = "example.com"
  type                = "externalEndpoints"
  geo_mappings        = ["FR", "DE"]
}
