
provider "azurerm" {
  features {}
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c" // Contributor role
}

data "azurerm_role_definition" "reader" {
  role_definition_id = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
}

data "azurerm_subscription" "test" {}

resource "azurerm_lighthouse_definition" "test" {
  lighthouse_definition_id = "56ea3d48-ec45-4301-a9e2-31639f28c648"
  name                     = "acctest-LD-230825024748429720"
  managing_tenant_id       = "ARM_TENANT_ID_ALT"
  scope                    = data.azurerm_subscription.test.id

  authorization {
    principal_id           = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id     = data.azurerm_role_definition.reader.role_definition_id
    principal_display_name = "Reader"
  }

  eligible_authorization {
    principal_id           = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id     = data.azurerm_role_definition.contributor.role_definition_id
    principal_display_name = "Tier 1 Support"

    just_in_time_access_policy {
      multi_factor_auth_provider  = "Azure"
      maximum_activation_duration = "PT7H"

      approver {
        principal_id           = "ARM_PRINCIPAL_ID_ALT_TENANT"
        principal_display_name = "Tier 2 Support"
      }
    }
  }
}
