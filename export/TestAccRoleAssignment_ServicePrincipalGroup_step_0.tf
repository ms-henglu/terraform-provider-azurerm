
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220211043231252848"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "74a9d2da-cb75-432d-bfc1-dc8455b91d1b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
