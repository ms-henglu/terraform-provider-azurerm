

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-230728032544156325"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutomation-230728032544156325"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"

  tags = {
    Environment = "Test"
  }
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230728032544156325"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-230728032544156325"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_log_analytics_linked_service" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  write_access_id     = azurerm_log_analytics_cluster.test.id
}
