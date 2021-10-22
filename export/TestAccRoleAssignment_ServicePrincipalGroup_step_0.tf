
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211022001656538672"
}

resource "azurerm_role_assignment" "test" {
  name                 = "025f7649-68a7-49c9-979f-bbe5c39618ff"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
