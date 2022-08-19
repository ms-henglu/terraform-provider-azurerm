
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "test" {}

data "azurerm_policy_set_definition" "test" {
  display_name = "Audit machines with insecure password security settings"
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-pa-220819165544836745"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestua220819165544836745"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_subscription_policy_assignment" "test" {
  name                 = "acctestpa-220819165544836745"
  subscription_id      = data.azurerm_subscription.test.id
  policy_definition_id = data.azurerm_policy_set_definition.test.id
  location             = "West Europe"
  description          = ""

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
