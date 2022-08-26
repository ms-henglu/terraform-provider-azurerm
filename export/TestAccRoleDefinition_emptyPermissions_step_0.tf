
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-220826005522655073"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-220826005522655073"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
