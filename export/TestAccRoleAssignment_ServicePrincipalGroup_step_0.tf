
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210917031343520902"
}

resource "azurerm_role_assignment" "test" {
  name                 = "c792ed03-5ada-43c2-bd47-3c22836cf404"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
