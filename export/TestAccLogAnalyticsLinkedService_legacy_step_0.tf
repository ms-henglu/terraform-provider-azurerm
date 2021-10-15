

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-211015014800545234"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctestAutomation-211015014800545234"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku_name = "Basic"

  tags = {
    Environment = "Test"
  }
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-211015014800545234"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_log_analytics_linked_service" "test" {
  resource_group_name = azurerm_resource_group.test.name
  workspace_name      = azurerm_log_analytics_workspace.test.name
  linked_service_name = "automation"
  resource_id         = azurerm_automation_account.test.id
}
