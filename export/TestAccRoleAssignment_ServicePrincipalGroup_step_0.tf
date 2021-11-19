
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-211119050518082780"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "754cbd30-2512-47d4-9f68-90a24b71f351"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
