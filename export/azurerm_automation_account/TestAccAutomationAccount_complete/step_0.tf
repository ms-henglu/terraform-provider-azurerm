
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231218071306453391"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                          = "acctest-231218071306453391"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  sku_name                      = "Basic"
  public_network_access_enabled = false
  local_authentication_enabled  = true
  tags = {
    "hello" = "world"
  }
}
