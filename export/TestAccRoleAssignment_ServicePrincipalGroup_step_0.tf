
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220722051613154907"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "612caf3e-6657-4728-aadc-f198930b3ddf"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
