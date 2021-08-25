
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {
}

resource "azuread_group" "test" {
  name = "acctestspa-210825025530417848"
}

resource "azurerm_role_assignment" "test" {
  name                 = "ad8fc847-c3ce-4fd5-b4b7-5352217c7a58"
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = azuread_group.test.id
}
