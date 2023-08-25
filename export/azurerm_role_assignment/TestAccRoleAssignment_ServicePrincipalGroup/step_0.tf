
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230825024038286910"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "93da5c90-1389-4c29-8134-37fd9d8cdecf"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
