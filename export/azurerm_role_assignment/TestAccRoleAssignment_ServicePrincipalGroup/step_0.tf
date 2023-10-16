
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-231016033408698683"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "a4ad96d1-0b5d-4ab9-8328-59202e6494b0"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
