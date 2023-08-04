
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230804025542219450"
  location = "West US"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-230804025542219450"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "QnAMaker"
  sku_name            = "S0"
}
