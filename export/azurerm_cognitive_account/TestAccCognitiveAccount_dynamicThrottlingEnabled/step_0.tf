
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-231016033517417130"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                       = "acctestcogacc-231016033517417130"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  kind                       = "LUIS"
  sku_name                   = "S0"
  dynamic_throttling_enabled = true
}
