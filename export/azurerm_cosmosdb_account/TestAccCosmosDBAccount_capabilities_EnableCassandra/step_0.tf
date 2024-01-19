
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-240119024752502858"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-240119024752502858"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {name = "EnableCassandra"}


  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
