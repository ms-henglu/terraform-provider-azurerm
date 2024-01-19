
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-240119024515586215"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-240119024515586215"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
