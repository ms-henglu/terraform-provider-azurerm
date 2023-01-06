

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-230106031449040358"
  location = "West Europe"
}


resource "azurerm_log_analytics_workspace" "default" {
  name                = "acctestLAW-230106031449040358"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-230106031449040358"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  insights {
    enabled                            = true
    retention_in_days                  = 7
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
  }
}
