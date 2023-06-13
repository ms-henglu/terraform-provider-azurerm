
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613072124390401"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                   = "acctestLAW-230613072124390401"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  internet_query_enabled = false
  sku                    = "PerGB2018"
  retention_in_days      = 30
}
