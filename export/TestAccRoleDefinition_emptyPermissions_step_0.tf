
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-211022001656547352"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-211022001656547352"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
