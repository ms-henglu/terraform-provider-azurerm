
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220225035127994194"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220225035127994194"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-220225035127994194"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_traffic_manager_external_endpoint" "test" {
  name              = "acctestend-azure220225035127994194"
  target            = "www.example.com"
  weight            = 5
  profile_id        = azurerm_traffic_manager_profile.test.id
  enabled           = false
  priority          = 4
  endpoint_location = azurerm_resource_group.test.location

  geo_mappings = ["WORLD"]

  custom_header {
    name  = "header"
    value = "www.bing.com"
  }
}
