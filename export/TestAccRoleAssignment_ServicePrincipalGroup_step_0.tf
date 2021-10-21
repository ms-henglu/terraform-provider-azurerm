
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211021234709329882"
}

resource "azurerm_role_assignment" "test" {
  name                 = "b87da098-1cd0-4c10-ba43-3a19117dcfc5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
