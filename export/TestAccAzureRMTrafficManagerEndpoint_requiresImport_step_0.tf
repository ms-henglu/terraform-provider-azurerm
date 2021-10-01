
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211001021323090546"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211001021323090546"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-211001021323090546"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-211001021323090546"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = "acctestpublicip-211001021323090546"
}

resource "azurerm_traffic_manager_endpoint" "testAzure" {
  name                = "acctestend-azure211001021323090546"
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.test.id
  weight              = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external211001021323090546"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  weight              = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}
