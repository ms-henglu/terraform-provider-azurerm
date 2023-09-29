


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230929064642334554"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230929064642334554"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {name = "EnableGremlin"}


  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_gremlin_database" "test" {
  name                = "acctest-230929064642334554"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
}


resource "azurerm_cosmosdb_gremlin_database" "import" {
  name                = azurerm_cosmosdb_gremlin_database.test.name
  resource_group_name = azurerm_cosmosdb_gremlin_database.test.resource_group_name
  account_name        = azurerm_cosmosdb_gremlin_database.test.account_name
}
