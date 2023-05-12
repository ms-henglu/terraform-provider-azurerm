


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-230512003649343149"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230512003649343149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                       = "accTest-CAEnv230512003649343149"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_container_app_environment" "import" {
  name                       = azurerm_container_app_environment.test.name
  resource_group_name        = azurerm_container_app_environment.test.resource_group_name
  location                   = azurerm_container_app_environment.test.location
  log_analytics_workspace_id = azurerm_container_app_environment.test.log_analytics_workspace_id
}
