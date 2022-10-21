
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-221021033808820748"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "cd21c8ad-7fdb-4177-8d73-3a3de149c27d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
