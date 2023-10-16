


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-231016034159731221"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutomation-231016034159731221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"

  tags = {
    Environment = "Test"
  }
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231016034159731221"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_log_analytics_linked_service" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  read_access_id      = azurerm_automation_account.test.id
}


resource "azurerm_log_analytics_linked_service" "import" {
  resource_group_name = azurerm_log_analytics_linked_service.test.resource_group_name
  workspace_id        = azurerm_log_analytics_linked_service.test.workspace_id
  read_access_id      = azurerm_log_analytics_linked_service.test.read_access_id
}
