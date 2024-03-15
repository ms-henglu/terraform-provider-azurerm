
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
}

resource "azurerm_lighthouse_definition" "test" {
  name               = "acctest-LD-240315123325765408"
  description        = "Acceptance Test Lighthouse Definition"
  managing_tenant_id = "ARM_TENANT_ID_ALT"
  scope              = data.azurerm_subscription.primary.id

  authorization {
    principal_id       = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id = data.azurerm_role_definition.contributor.role_definition_id
  }
}

resource "azurerm_lighthouse_assignment" "test" {
  name                     = "dbaa9186-3baf-45ee-8bc4-14a330572afd"
  scope                    = data.azurerm_subscription.primary.id
  lighthouse_definition_id = azurerm_lighthouse_definition.test.id
}
