

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230602030332781895"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230602030332781895"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_account" "import" {
  name                = azurerm_cosmosdb_account.test.name
  location            = azurerm_cosmosdb_account.test.location
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  offer_type          = azurerm_cosmosdb_account.test.offer_type

  consistency_policy {
    consistency_level = azurerm_cosmosdb_account.test.consistency_policy[0].consistency_level
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
