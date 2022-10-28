
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-221028171823684973"
  location = "West US"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-221028171823684973"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "QnAMaker"
  sku_name            = "S0"
}
