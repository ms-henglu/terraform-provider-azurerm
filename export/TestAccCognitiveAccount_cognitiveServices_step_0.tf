
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-220527033911600993"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-220527033911600993"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}
