
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221019060312725329"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "22b0966d-f6a9-4ca3-bd36-80ce1b69ff0b"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
