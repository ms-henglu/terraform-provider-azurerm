

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230804025710171847"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230804025710171847"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_sql_database" "test" {
  name                = "acctest-230804025710171847"
  resource_group_name = azurerm_cosmosdb_account.test.resource_group_name
  account_name        = azurerm_cosmosdb_account.test.name
  autoscale_settings {
    max_throughput = 4000
  }
}
