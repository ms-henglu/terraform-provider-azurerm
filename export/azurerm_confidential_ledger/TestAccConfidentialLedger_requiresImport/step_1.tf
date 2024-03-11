

provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-ledger-240311031629071365"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "first" {
  name                = "acctest-uai1-240311031629071365"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_user_assigned_identity" "second" {
  name                = "acctest-uai2-240311031629071365"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_confidential_ledger" "test" {
  name                = "acctest-tfci-240311031629071365"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ledger_type         = "Public"

  azuread_based_service_principal {
    ledger_role_name = "Administrator"
    principal_id     = data.azurerm_client_config.current.object_id
    tenant_id        = data.azurerm_client_config.current.tenant_id
  }
}


resource "azurerm_confidential_ledger" "import" {
  name                = azurerm_confidential_ledger.test.name
  resource_group_name = azurerm_confidential_ledger.test.resource_group_name
  location            = azurerm_confidential_ledger.test.location
  ledger_type         = azurerm_confidential_ledger.test.ledger_type

  azuread_based_service_principal {
    ledger_role_name = azurerm_confidential_ledger.test.azuread_based_service_principal.0.ledger_role_name
    principal_id     = azurerm_confidential_ledger.test.azuread_based_service_principal.0.principal_id
    tenant_id        = azurerm_confidential_ledger.test.azuread_based_service_principal.0.tenant_id
  }
}
