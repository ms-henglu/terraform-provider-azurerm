
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230113180814905603"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                       = "acctestcogacc-230113180814905603"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  kind                       = "LUIS"
  sku_name                   = "S0"
  dynamic_throttling_enabled = true
}
