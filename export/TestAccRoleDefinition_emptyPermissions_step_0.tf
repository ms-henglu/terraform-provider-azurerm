
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-210830083701090619"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-210830083701090619"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
