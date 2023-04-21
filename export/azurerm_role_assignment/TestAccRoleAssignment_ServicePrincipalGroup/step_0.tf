
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230421021706839456"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6b57ca0e-14a2-4ebb-a2a7-efe5b4a53fe7"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
