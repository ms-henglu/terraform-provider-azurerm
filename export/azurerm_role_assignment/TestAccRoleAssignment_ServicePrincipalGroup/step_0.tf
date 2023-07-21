
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230721011145763072"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "9645654e-cc9f-4bf7-8a18-5c256a10ea9c"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
