
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230922060857847875"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230922060857847875"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  capabilities {name = "EnableMongo"}
capabilities {name = "AllowSelfServeUpgradeToMongo36"}


  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
