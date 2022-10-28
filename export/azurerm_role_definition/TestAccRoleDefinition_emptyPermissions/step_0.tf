
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-221028171734169377"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-221028171734169377"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
