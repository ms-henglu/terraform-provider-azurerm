

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
}

resource "azurerm_lighthouse_definition" "test" {
  name               = "acctest-LD-221117231045432469"
  description        = "Acceptance Test Lighthouse Definition"
  managing_tenant_id = "ARM_TENANT_ID_ALT"
  scope              = data.azurerm_subscription.primary.id

  authorization {
    principal_id       = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id = data.azurerm_role_definition.contributor.role_definition_id
  }
}

resource "azurerm_lighthouse_assignment" "test" {
  name                     = "f4a0624d-17ea-4b6a-be2d-0df719660994"
  scope                    = data.azurerm_subscription.primary.id
  lighthouse_definition_id = azurerm_lighthouse_definition.test.id
}


resource "azurerm_lighthouse_assignment" "import" {
  name                     = azurerm_lighthouse_assignment.test.name
  lighthouse_definition_id = azurerm_lighthouse_assignment.test.lighthouse_definition_id
  scope                    = azurerm_lighthouse_assignment.test.scope
}
