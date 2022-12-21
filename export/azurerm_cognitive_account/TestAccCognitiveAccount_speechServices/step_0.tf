
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-221221204029075484"
  location = "West US 2"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-221221204029075484"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}
