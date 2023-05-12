
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230512003439934855"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "04f814bc-2739-46f2-9a85-c0b73842520f"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
