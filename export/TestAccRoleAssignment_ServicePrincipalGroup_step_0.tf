
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211015014329813649"
}

resource "azurerm_role_assignment" "test" {
  name                 = "cef33dcd-64bc-4ce7-9829-29328bb5c529"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
