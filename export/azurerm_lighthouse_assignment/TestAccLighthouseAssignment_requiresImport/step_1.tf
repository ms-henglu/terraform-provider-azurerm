

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

data "azurerm_role_definition" "contributor" {
  role_definition_id = "b24988ac-6180-42a0-ab88-20f7382dd24c"
}

resource "azurerm_lighthouse_definition" "test" {
  name               = "acctest-LD-230818024236911624"
  description        = "Acceptance Test Lighthouse Definition"
  managing_tenant_id = "ARM_TENANT_ID_ALT"
  scope              = data.azurerm_subscription.primary.id

  authorization {
    principal_id       = "ARM_PRINCIPAL_ID_ALT_TENANT"
    role_definition_id = data.azurerm_role_definition.contributor.role_definition_id
  }
}

resource "azurerm_lighthouse_assignment" "test" {
  name                     = "cd7e595a-fc69-40cd-ad31-a14c4079b89c"
  scope                    = data.azurerm_subscription.primary.id
  lighthouse_definition_id = azurerm_lighthouse_definition.test.id
}


resource "azurerm_lighthouse_assignment" "import" {
  name                     = azurerm_lighthouse_assignment.test.name
  lighthouse_definition_id = azurerm_lighthouse_assignment.test.lighthouse_definition_id
  scope                    = azurerm_lighthouse_assignment.test.scope
}
