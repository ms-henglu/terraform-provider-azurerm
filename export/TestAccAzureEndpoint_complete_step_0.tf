
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220506010343868611"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220506010343868611"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-220506010343868611"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}


resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-220506010343868611"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = "acctestpublicip-220506010343868611"
}

resource "azurerm_traffic_manager_azure_endpoint" "test" {
  name               = "acctestend-azure220506010343868611"
  target_resource_id = azurerm_public_ip.test.id
  weight             = 3
  profile_id         = azurerm_traffic_manager_profile.test.id
}
