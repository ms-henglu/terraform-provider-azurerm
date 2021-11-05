
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211105035542370514"
}

resource "azurerm_role_assignment" "test" {
  name                 = "7e95d4cd-faac-45af-886b-a571e4126b42"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
