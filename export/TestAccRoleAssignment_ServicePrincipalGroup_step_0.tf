
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-211001053448308702"
}

resource "azurerm_role_assignment" "test" {
  name                 = "35575ce8-b42a-408c-ba58-e1ed0d037493"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
