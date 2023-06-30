
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230630032807734150"
  location = "West Europe"
}
resource "azurerm_cognitive_account" "test" {
  name                       = "acctestcogacc-230630032807734150"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  kind                       = "LUIS"
  sku_name                   = "S0"
  dynamic_throttling_enabled = true
}
