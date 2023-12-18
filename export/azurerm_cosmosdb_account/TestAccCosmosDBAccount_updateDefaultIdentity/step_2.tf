
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-231218071521485466"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                  = "acctest-ca-231218071521485466"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  offer_type            = "Standard"
  kind                  = "GlobalDocumentDB"
  default_identity_type = "FirstPartyIdentity"

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
