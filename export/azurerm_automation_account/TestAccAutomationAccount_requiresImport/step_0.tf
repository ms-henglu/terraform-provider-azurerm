
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230313020743498797"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-230313020743498797"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}
