

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-240119025046824675"
  location = "West Europe"
}


resource "azurerm_log_analytics_workspace" "default" {
  name                = "acctestLAW-240119025046824675"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_workspace" "regional" {
  name                = "acctestLAW-region-240119025046824675"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-networkfw-Policy-240119025046824675"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  insights {
    enabled                            = true
    retention_in_days                  = 7
    default_log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
    log_analytics_workspace {
      id                = azurerm_log_analytics_workspace.regional.id
      firewall_location = "West Europe"
    }
  }
}
