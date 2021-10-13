
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072032215353"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211013072032215353"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  retention_in_days   = 30
}
