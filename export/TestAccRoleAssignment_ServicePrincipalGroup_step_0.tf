
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221019053857955353"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "f95b6866-7baf-40ef-ac9c-b960c5b7a2c2"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
