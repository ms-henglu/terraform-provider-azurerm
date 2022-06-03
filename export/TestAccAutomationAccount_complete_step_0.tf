
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-220603004549525266"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                          = "acctest-220603004549525266"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku_name                      = "Basic"
  public_network_access_enabled = false
  tags = {
    "hello" = "world"
  }
}
