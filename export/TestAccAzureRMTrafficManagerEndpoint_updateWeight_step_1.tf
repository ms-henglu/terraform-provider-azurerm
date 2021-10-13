
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211013072504593099"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211013072504593099"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-211013072504593099"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external211013072504593099"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  weight              = 25
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_traffic_manager_endpoint" "testExternalNew" {
  name                = "acctestend-external211013072504593099-2"
  type                = "externalEndpoints"
  target              = "www.pluginsdk.io"
  weight              = 75
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}
