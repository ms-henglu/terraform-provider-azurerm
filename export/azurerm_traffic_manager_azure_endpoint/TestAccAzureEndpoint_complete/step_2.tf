
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-230721020216812302"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-230721020216812302"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-230721020216812302"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-230721020216812302"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = "acctestpublicip-230721020216812302"
}

resource "azurerm_traffic_manager_azure_endpoint" "test" {
  name               = "acctestend-azure230721020216812302"
  target_resource_id = azurerm_public_ip.test.id
  weight             = 5
  profile_id         = azurerm_traffic_manager_profile.test.id
  enabled            = false
  priority           = 4

  geo_mappings = ["WORLD"]

  custom_header {
    name  = "header"
    value = "www.bing.com"
  }
}
