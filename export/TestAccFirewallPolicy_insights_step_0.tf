

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-220603004857906883"
  location = "West Europe"
}


resource "azurerm_log_analytics_workspace" "default" {
  name                = "acctestLAW-220603004857906883"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-220603004857906883"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  insights {
    enabled                            = true
    retention_in_days                  = 7
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
  }
}
