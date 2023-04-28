
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230428045223223559"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "4de0442c-60f5-420b-b0b1-2843f9e7b765"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
