
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
  lighthouse_definition_id = "b0302742-f686-45a4-be31-c442ddc36bd2"
  name                     = "acctest-LD-231016034138640590"
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
