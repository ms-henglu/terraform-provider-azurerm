
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-240119024426251200"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctest-240119024426251200"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-240119024426251200"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  application_type    = "web"
}
