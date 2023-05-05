
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230505045852928673"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "ae9d05dd-dae7-4713-8476-22c8893fe1a5"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
