
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-210826023107622878"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-210826023107622878"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"
}
