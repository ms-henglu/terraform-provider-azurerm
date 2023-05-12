
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-230512010230737651"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-230512010230737651"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
