
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAEnv-230915023123082788"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-230915023123082788"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv230915023123082788"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctwfp7d"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "container-app-storage"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_container_app_environment_dapr_component" "test" {
  name                         = "acctest-dapr-230915023123082788"
  container_app_environment_id = azurerm_container_app_environment.test.id
  component_type               = "state.azure.blobstorage"
  version                      = "v2"

  init_timeout  = "5s"
  ignore_errors = false

  secret {
    name  = "storage-account-access-key"
    value = azurerm_storage_account.test.secondary_access_key
  }

  metadata {
    name        = "storage-account-key"
    secret_name = "storage-account-access-key"
  }

  metadata {
    name  = "storage-container-name"
    value = azurerm_storage_container.test.name
  }

  metadata {
    name  = "SOME_APP_SETTING"
    value = "plumbus"
  }

  scopes = ["testapp", "updatedapp"]
}
