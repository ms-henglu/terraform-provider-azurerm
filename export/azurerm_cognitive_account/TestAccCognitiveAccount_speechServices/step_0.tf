
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-240119024621916002"
  location = "West US 2"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-240119024621916002"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "SpeechServices"
  sku_name            = "S0"
}
