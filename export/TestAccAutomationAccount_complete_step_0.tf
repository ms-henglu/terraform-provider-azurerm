
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-210924003918042810"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-210924003918042810"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"

  tags = {
    "hello" = "world"
  }
}
