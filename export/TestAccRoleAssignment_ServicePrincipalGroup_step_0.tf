
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210928055146807681"
}

resource "azurerm_role_assignment" "test" {
  name                 = "28d2233f-0d35-4e14-a05c-3cf964e50d4e"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
