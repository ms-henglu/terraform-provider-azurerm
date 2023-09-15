
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230915022905262991"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "b3d78e11-e492-4efa-afb1-ffad88355dda"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
