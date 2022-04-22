
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220422024806987765"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "6166ee77-69cf-437f-b7fe-20d3f7e1e62d"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
