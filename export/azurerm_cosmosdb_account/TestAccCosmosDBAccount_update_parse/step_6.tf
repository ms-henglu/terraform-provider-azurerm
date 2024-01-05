

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240105063548813414"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VNET-240105063548813414"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "acctest-SN1-240105063548813414-1"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "acctest-SN2-240105063548813414-2"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.AzureCosmosDB"]
}


resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-240105063548813414"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "Parse"

  capabilities {
    name = "AllowSelfServeUpgradeToMongo36"
  }

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  consistency_policy {
    consistency_level       = "Eventual"
    max_interval_in_seconds = 360
    max_staleness_prefix    = 170000
  }

  is_virtual_network_filter_enabled = true

  virtual_network_rule {
    id = azurerm_subnet.subnet2.id
  }

  enable_multiple_write_locations = true

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  geo_location {
    location          = "West US 2"
    failover_priority = 1
  }

  geo_location {
    location          = "East US 2"
    failover_priority = 2
  }

  cors_rule {
    allowed_origins    = ["http://www.example.com", "http://www.test.com"]
    exposed_headers    = ["x-tempo-*", "x-method-*"]
    allowed_headers    = ["*"]
    allowed_methods    = ["GET"]
    max_age_in_seconds = 2147483647
  }

  access_key_metadata_writes_enabled = true
}
