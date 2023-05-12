


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAEnv-230512010421795361"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-230512010421795361"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "accTest-CAEnv230512010421795361"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_container_app_environment_dapr_component" "test" {
  name                         = "acctest-dapr-230512010421795361"
  container_app_environment_id = azurerm_container_app_environment.test.id
  component_type               = "state.azure.blobstorage"
  version                      = "v1"
}



resource "azurerm_container_app_environment_dapr_component" "import" {
  name                         = azurerm_container_app_environment_dapr_component.test.name
  container_app_environment_id = azurerm_container_app_environment_dapr_component.test.container_app_environment_id
  component_type               = azurerm_container_app_environment_dapr_component.test.component_type
  version                      = azurerm_container_app_environment_dapr_component.test.version
}

