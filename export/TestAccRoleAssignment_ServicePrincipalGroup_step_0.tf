
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220527033831535281"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "af1d0ec9-2081-480f-85da-b8c238c48d0c"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
