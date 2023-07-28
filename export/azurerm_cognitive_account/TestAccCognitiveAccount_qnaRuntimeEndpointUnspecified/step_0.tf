
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230728025220640996"
  location = "West US"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-230728025220640996"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "QnAMaker"
  sku_name            = "S0"
}
