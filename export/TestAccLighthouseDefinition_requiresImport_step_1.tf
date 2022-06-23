

provider "azurerm" {
  features {}
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
}

data "azurerm_subscription" "test" {}

resource "azurerm_lighthouse_definition" "test" {
  lighthouse_definition_id = "7fc56b72-5fb6-481a-9afd-1b5561d9308e"
  name                     = "acctest-LD-220623233854322927"
  managing_tenant_id       = "ARM_TENANT_ID_ALT"
  scope                    = data.azurerm_subscription.test.id

  authorization {
    principal_id           = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id     = data.azurerm_role_definition.contributor.role_definition_id
    principal_display_name = "Tier 1 Support"
  }
}


resource "azurerm_lighthouse_definition" "import" {
  name                     = azurerm_lighthouse_definition.test.name
  lighthouse_definition_id = azurerm_lighthouse_definition.test.lighthouse_definition_id
  managing_tenant_id       = azurerm_lighthouse_definition.test.managing_tenant_id
  scope                    = azurerm_lighthouse_definition.test.scope
  authorization {
    principal_id       = azurerm_lighthouse_definition.test.managing_tenant_id
    role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
  }
}
