
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-211210024322744613"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-211210024322744613"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"

  tags = {
    "hello" = "world"
  }
}
