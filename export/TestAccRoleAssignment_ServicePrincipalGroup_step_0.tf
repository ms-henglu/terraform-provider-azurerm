
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211029015234975814"
}

resource "azurerm_role_assignment" "test" {
  name                 = "3e4013bf-a579-4842-85c9-102249d40ff6"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
