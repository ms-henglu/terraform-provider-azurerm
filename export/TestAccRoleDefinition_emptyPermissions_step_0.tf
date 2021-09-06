
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-210906021951924701"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-210906021951924701"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
