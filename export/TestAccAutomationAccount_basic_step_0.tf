
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-220630210506596335"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-220630210506596335"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}
