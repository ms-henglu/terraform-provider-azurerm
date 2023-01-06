
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230106034132607386"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230106034132607386"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}
