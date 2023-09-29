
provider "azurerm" {
  subscription_id = ""
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "test" {}

data "azurerm_blueprint_definition" "test" {
  name     = "testAcc_basicSubscription"
  scope_id = data.azurerm_subscription.test.id
}

data "azurerm_blueprint_published_version" "test" {
  scope_id       = data.azurerm_blueprint_definition.test.scope_id
  blueprint_name = data.azurerm_blueprint_definition.test.name
  version        = "v0.2_testAcc"
}

resource "azurerm_resource_group" "test" {
  name     = "accTestRG-bp-230929064453950486"
  location = "westeurope"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "bp-user-230929064453950486"
}

resource "azurerm_role_assignment" "test" {
  scope                = data.azurerm_subscription.test.id
  role_definition_name = "Blueprint Operator"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_blueprint_assignment" "test" {
  name                   = "testAccBPAssignment230929064453950486"
  target_subscription_id = data.azurerm_subscription.test.id
  version_id             = data.azurerm_blueprint_published_version.test.id
  location               = "West Europe"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  depends_on = [
    azurerm_role_assignment.test
  ]
}
