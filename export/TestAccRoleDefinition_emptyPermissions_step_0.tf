
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-211001053448307876"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-211001053448307876"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
