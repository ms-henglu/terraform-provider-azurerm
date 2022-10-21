
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-221021030847875847"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-221021030847875847"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }
}
