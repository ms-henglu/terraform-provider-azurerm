

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-220107064831521062"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-220107064831521062"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "acctest-tmp-220107064831521062"
    ttl           = 30
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-220107064831521062"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  domain_name_label   = "acctestpublicip-220107064831521062"
}

resource "azurerm_traffic_manager_endpoint" "testAzure" {
  name                = "acctestend-azure220107064831521062"
  type                = "azureEndpoints"
  target_resource_id  = azurerm_public_ip.test.id
  weight              = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_traffic_manager_endpoint" "testExternal" {
  name                = "acctestend-external220107064831521062"
  type                = "externalEndpoints"
  target              = "pluginsdk.io"
  weight              = 3
  profile_name        = azurerm_traffic_manager_profile.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_traffic_manager_endpoint" "import" {
  name                = azurerm_traffic_manager_endpoint.testAzure.name
  type                = azurerm_traffic_manager_endpoint.testAzure.type
  target_resource_id  = azurerm_traffic_manager_endpoint.testAzure.target_resource_id
  weight              = azurerm_traffic_manager_endpoint.testAzure.weight
  profile_name        = azurerm_traffic_manager_endpoint.testAzure.profile_name
  resource_group_name = azurerm_traffic_manager_endpoint.testAzure.resource_group_name
}
