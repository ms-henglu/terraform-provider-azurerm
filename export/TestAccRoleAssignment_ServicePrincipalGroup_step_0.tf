
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-220610092324749246"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "85ad24e6-078f-413a-bde1-0bee9ecd3704"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
