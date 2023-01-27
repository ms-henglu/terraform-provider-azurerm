
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045642206893"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                            = "acctestLAW-230127045642206893"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  sku                             = "PerGB2018"
  retention_in_days               = 30
  allow_resource_only_permissions = true
}
