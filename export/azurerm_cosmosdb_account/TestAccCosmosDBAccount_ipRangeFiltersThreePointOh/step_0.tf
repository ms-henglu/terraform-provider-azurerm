

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230922060857854900"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VNET-230922060857854900"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "subnet1" {
  name                                           = "acctest-SN1-230922060857854900-1"
  resource_group_name                            = azurerm_resource_group.test.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  address_prefixes                               = ["10.0.1.0/24"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
}

resource "azurerm_subnet" "subnet2" {
  name                                           = "acctest-SN2-230922060857854900-2"
  resource_group_name                            = azurerm_resource_group.test.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  address_prefixes                               = ["10.0.2.0/24"]
  service_endpoints                              = ["Microsoft.AzureCosmosDB"]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
}


resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230922060857854900"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_multiple_write_locations = false
  enable_automatic_failover       = false

  consistency_policy {
    consistency_level       = "Eventual"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  is_virtual_network_filter_enabled = true
  ip_range_filter                   = "55.0.1.0/24"

  virtual_network_rule {
    id                                   = azurerm_subnet.subnet1.id
    ignore_missing_vnet_service_endpoint = true
  }

  virtual_network_rule {
    id                                   = azurerm_subnet.subnet2.id
    ignore_missing_vnet_service_endpoint = false
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
