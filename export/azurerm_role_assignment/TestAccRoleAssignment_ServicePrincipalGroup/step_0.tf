
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-240105060258079552"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "d2ba451d-06cf-470e-861f-3f80075acb7d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
