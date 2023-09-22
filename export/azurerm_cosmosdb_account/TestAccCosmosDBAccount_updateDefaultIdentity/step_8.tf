
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230922053906090911"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "acctest-user-example"
}

resource "azurerm_cosmosdb_account" "test" {
  name                  = "acctest-ca-230922053906090911"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  offer_type            = "Standard"
  kind                  = "GlobalDocumentDB"
  default_identity_type = join("=", ["UserAssignedIdentity", azurerm_user_assigned_identity.test.id])

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  consistency_policy {
    consistency_level = "Eventual"
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }
}
