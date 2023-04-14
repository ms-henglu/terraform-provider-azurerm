
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230414021037445694"
  location = "West Europe"
}

resource "azurerm_cosmosdb_account" "test" {
  name                  = "acctest-ca-230414021037445694"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  offer_type            = "Standard"
  kind                  = "GlobalDocumentDB"
  default_identity_type = "SystemAssignedIdentity"

  identity {
    type = "SystemAssigned"
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
