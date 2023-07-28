
provider "azurerm" {
  features {}
}


data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-ledger-230728025302794417"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "first" {
  name                = "acctest-uai1-230728025302794417"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_user_assigned_identity" "second" {
  name                = "acctest-uai2-230728025302794417"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_confidential_ledger" "test" {
  name                = "acctest-tfci-230728025302794417"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  ledger_type         = "Private"

  azuread_based_service_principal {
    ledger_role_name = "Administrator"
    principal_id     = data.azurerm_client_config.current.object_id
    tenant_id        = data.azurerm_client_config.current.tenant_id
  }

  azuread_based_service_principal {
    ledger_role_name = "Reader"
    principal_id     = azurerm_user_assigned_identity.first.principal_id
    tenant_id        = azurerm_user_assigned_identity.first.tenant_id
  }

  azuread_based_service_principal {
    ledger_role_name = "Reader"
    principal_id     = azurerm_user_assigned_identity.second.principal_id
    tenant_id        = azurerm_user_assigned_identity.second.tenant_id
  }

  tags = {
    Environment = "Testing"
  }
}
