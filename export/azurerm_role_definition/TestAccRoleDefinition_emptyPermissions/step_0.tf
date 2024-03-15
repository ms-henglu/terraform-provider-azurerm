
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-240315122327830413"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-240315122327830413"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
