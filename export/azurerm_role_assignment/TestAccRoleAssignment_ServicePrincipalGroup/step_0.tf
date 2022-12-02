
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221202035146545523"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "58bca3ab-c080-4110-a51e-d9cfb31b33a9"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
