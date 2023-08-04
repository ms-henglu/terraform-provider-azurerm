
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cosmos-230804025710148509"
  location = "westeurope"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "acctest-user-example"
}

resource "azurerm_cosmosdb_account" "test" {
  name                = "acctest-ca-230804025710148509"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 5
    max_staleness_prefix    = 100
  }

  geo_location {
    location          = azurerm_resource_group.test.location
    failover_priority = 0
  }

  default_identity_type = join("=", ["UserAssignedIdentity", azurerm_user_assigned_identity.test.id])

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  tags = {
    environment  = "Sandbox",
    created_date = "2023-07-18"
  }
}
