
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
}

resource "azurerm_lighthouse_definition" "test" {
  name               = "acctest-LD-220623233854324789"
  description        = "Acceptance Test Lighthouse Definition"
  managing_tenant_id = "ARM_TENANT_ID_ALT"
  scope              = data.azurerm_subscription.primary.id

  authorization {
    principal_id       = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id = data.azurerm_role_definition.contributor.role_definition_id
  }
}

resource "azurerm_lighthouse_assignment" "test" {
  name                     = "3ab04741-95d7-4619-9601-b5a04e1690a9"
  scope                    = data.azurerm_subscription.primary.id
  lighthouse_definition_id = azurerm_lighthouse_definition.test.id
}
