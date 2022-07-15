
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220715005000102232"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220715005000102232"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "acctest-tmp-220715005000102232"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-220715005000102232"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = "acctestpublicip-220715005000102232"
}

resource "azurerm_traffic_manager_azure_endpoint" "test" {
  name               = "acctestend-azure220715005000102232"
  target_resource_id = azurerm_public_ip.test.id
  profile_id         = azurerm_traffic_manager_profile.test.id
}
