
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230227175125747636"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230227175125747636"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}
