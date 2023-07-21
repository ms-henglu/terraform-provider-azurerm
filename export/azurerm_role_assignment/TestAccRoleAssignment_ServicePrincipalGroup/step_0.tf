
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230721014459553639"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "184f41a6-0ca4-4067-9af4-02e698c5993a"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
