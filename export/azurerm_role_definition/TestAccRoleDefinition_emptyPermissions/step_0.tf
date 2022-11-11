
provider "azurerm" {
  features {}
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-221111013108647522"
  location = "West Europe"
}

resource "azurerm_role_definition" "test" {
  name              = "acctestrd-221111013108647522"
  scope             = azurerm_resource_group.test.id
  assignable_scopes = [azurerm_resource_group.test.id]
}
