
provider "azurerm" {
  features {}
}

data "azurerm_role_definition" "reader" {
  role_definition_id = "acdd72a7-3385-48ef-bd42-f606fba81ae7"
}

data "azurerm_subscription" "test" {}

resource "azurerm_lighthouse_definition" "test" {
  name               = "acctest-LD-231218072004744339"
  description        = "Acceptance Test Lighthouse Definition"
  managing_tenant_id = "ARM_TENANT_ID_ALT"
  scope              = data.azurerm_subscription.test.id

  authorization {
    principal_id           = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id     = data.azurerm_role_definition.reader.role_definition_id
    principal_display_name = "Reader"
  }

  plan {
    name      = "ARM_PLAN_NAME"
    publisher = "ARM_PLAN_PUBLISHER"
    product   = "ARM_PLAN_PRODUCT"
    version   = "ARM_PLAN_VERSION"
  }
}
