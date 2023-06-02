
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-ledger-230602030254890710"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "first" {
  name                = "acctest-uai1-230602030254890710"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_user_assigned_identity" "second" {
  name                = "acctest-uai2-230602030254890710"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_confidential_ledger" "test" {
  name                = "acctest-230602030254890710"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ledger_type         = "Public"

  azuread_based_service_principal {
    ledger_role_name = "Administrator"
    principal_id     = data.azurerm_client_config.current.object_id
    tenant_id        = data.azurerm_client_config.current.tenant_id
  }
}
