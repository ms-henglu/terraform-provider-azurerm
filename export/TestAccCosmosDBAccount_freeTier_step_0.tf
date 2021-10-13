
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-211013071658612694"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-211013071658612694"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_free_tier = true

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
