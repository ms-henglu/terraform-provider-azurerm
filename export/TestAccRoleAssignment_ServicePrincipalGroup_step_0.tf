
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210924010706678900"
}

resource "azurerm_role_assignment" "test" {
  name                 = "895ce622-8000-47b9-918d-f561c6dfbe16"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
