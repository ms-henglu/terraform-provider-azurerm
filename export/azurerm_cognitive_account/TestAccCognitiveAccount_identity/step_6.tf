
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-240119024621923697"
  location = "West Europe"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-240119024621923697"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Face"
  sku_name            = "S0"
  identity {
    type = "SystemAssigned"
  }
}
