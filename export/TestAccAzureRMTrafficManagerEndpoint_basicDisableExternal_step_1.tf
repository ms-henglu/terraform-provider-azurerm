
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211217080004222251"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211217080004222251"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-211217080004222251"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-211217080004222251"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = "acctestpublicip-211217080004222251"
}

resource "azurerm_traffic_manager_endpoint" "testAzure" {
  name                = "acctestend-azure211217080004222251"
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.test.id
  weight              = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external211217080004222251"
  endpoint_status     = "Disabled"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  weight              = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}
