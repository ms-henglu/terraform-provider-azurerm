
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221028164618984082"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-221028164618984082"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}
