

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034159739542"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016034159739542"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_log_analytics_workspace" "import" {
  name                = azurerm_log_analytics_workspace.test.name
  location            = azurerm_log_analytics_workspace.test.location
  resource_group_name = azurerm_log_analytics_workspace.test.resource_group_name
  sku                 = "PerGB2018"
}
