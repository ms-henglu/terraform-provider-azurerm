


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-230324051819531120"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230324051819531120"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                       = "accTest-CAEnv230324051819531120"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-230324051819531120"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  template {
    container {
      name   = "acctest-cont-230324051819531120"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}


resource "azurerm_container_app" "import" {
  name                         = azurerm_container_app.test.name
  resource_group_name          = azurerm_container_app.test.resource_group_name
  container_app_environment_id = azurerm_container_app.test.container_app_environment_id
  revision_mode                = azurerm_container_app.test.revision_mode

  template {
    container {
      name   = azurerm_container_app.test.template.0.container.0.name
      image  = azurerm_container_app.test.template.0.container.0.image
      cpu    = azurerm_container_app.test.template.0.container.0.cpu
      memory = azurerm_container_app.test.template.0.container.0.memory
    }
  }
}
