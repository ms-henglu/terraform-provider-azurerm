
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAEnv-240112224153846805"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-240112224153846805"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv240112224153846805"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctzbg7s"
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
  name                         = "acctest-dapr-240112224153846805"
  container_app_environment_id = azurerm_container_app_environment.test.id
  component_type               = "state.azure.blobstorage"
  version                      = "v1"

  init_timeout  = "10s"
  ignore_errors = true

  secret {
    name  = "secret"
    value = "sauce"
  }

  secret {
    name  = "storage-account-access-key"
    value = azurerm_storage_account.test.primary_access_key
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
    value = "scwiffy"
  }

  scopes = ["testapp"]
}


