
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-230602030139969133"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-230602030139969133"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
