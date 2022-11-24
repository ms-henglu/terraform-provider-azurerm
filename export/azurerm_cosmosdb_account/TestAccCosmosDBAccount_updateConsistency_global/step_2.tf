
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-221124181435541608"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-221124181435541608"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "Strong"
    max_interval_in_seconds = 8
    max_staleness_prefix    = 880
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
