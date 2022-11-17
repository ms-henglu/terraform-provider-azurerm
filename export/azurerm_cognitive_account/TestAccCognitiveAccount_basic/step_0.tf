
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-221117230603129776"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-221117230603129776"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Face"
  sku_name            = "S0"
}
