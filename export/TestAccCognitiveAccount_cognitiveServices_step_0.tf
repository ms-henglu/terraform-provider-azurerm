
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-211013071618978758"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-211013071618978758"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}
