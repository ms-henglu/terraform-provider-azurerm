
provider "azurerm" {
  features {}
}

data "azurerm_role_definition" "user_access_administrator" {
  role_definition_id = "18d7d88d-d35e-4fb5-a5c3-7773c20a72d9"
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
}

data "azurerm_subscription" "test" {}

resource "azurerm_lighthouse_definition" "test" {
  lighthouse_definition_id = "54863ea5-4226-4037-ae70-b8d7ced63ac9"
  name                     = "acctest-LD-230113181258070303"
  description              = "Acceptance Test Lighthouse Definition"
  managing_tenant_id       = "ARM_TENANT_ID_ALT"
  scope                    = data.azurerm_subscription.test.id

  authorization {
    principal_id                  = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id            = data.azurerm_role_definition.user_access_administrator.role_definition_id
    principal_display_name        = "Tier 2 Support"
    delegated_role_definition_ids = [data.azurerm_role_definition.contributor.role_definition_id]
  }
}
