
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210825031423430653"
}

resource "azurerm_role_assignment" "test" {
  name                 = "b1949200-2b87-46ee-81e2-38c43f61c7bd"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
