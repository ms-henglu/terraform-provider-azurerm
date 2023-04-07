
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  display_name     = "acctestspa-230407022924637964"
  security_enabled = true
}

resource "azurerm_role_assignment" "test" {
  name                 = "5852a528-56e8-4ff6-9d0c-d244517b9117"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
