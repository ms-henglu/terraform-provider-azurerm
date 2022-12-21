
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "test" {}

data "azurerm_management_group" "root" {
  name = data.azurerm_client_config.current.tenant_id
}

data "azurerm_blueprint_definition" "test" {
  name     = "testAcc_basicRootManagementGroup"
  scope_id = data.azurerm_management_group.root.id
}

data "azurerm_blueprint_published_version" "test" {
  scope_id       = data.azurerm_blueprint_definition.test.scope_id
  blueprint_name = data.azurerm_blueprint_definition.test.name
  version        = "v0.1_testAcc"
}

resource "azurerm_resource_group" "test" {
  name     = "accTestRG-bp-221221204013660600"
  location = "West Europe"

  tags = {
    testAcc = "true"
  }
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "bp-user-221221204013660600"
}

resource "azurerm_role_assignment" "operator" {
  scope                = data.azurerm_subscription.test.id
  role_definition_name = "Blueprint Operator"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_role_assignment" "owner" {
  scope                = data.azurerm_subscription.test.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.test.principal_id
}

resource "azurerm_blueprint_assignment" "test" {
  name                   = "testAccBPAssignment221221204013660600"
  target_subscription_id = data.azurerm_subscription.test.id
  version_id             = data.azurerm_blueprint_published_version.test.id
  location               = "West Europe"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  depends_on = [
    azurerm_role_assignment.operator,
    azurerm_role_assignment.owner
  ]
}
