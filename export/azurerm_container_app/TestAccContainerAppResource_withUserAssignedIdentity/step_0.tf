

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-230721014741180048"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230721014741180048"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv230721014741180048"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acct-230721014741180048"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-230721014741180048"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  template {
    container {
      name   = "acctest-cont-230721014741180048"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
