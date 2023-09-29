


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAEnv-230929064613392944"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestCAEnv-230929064613392944"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv230929064613392944"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
}


resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctwkmwi"
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
  name                         = "acctest-dapr-230929064613392944"
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




resource "azurerm_container_registry" "test" {
  name                = "testacccr230929064613392944"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
  admin_enabled       = true

  network_rule_set = []
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharewkmwi"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_container_app_environment_storage" "test" {
  name                         = "testacc-caes-230929064613392944"
  container_app_environment_id = azurerm_container_app_environment.test.id
  account_name                 = azurerm_storage_account.test.name
  access_key                   = azurerm_storage_account.test.primary_access_key
  share_name                   = azurerm_storage_share.test.name
  access_mode                  = "ReadWrite"
}


resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-230929064613392944"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Multiple"

  template {
    container {
      name  = "acctest-cont-230929064613392944"
      image = "jackofallops/azure-containerapps-python-acctest:v0.0.1"

      cpu    = 0.5
      memory = "1Gi"

      readiness_probe {
        transport               = "HTTP"
        port                    = 5000
        path                    = "/uptime"
        timeout                 = 2
        failure_count_threshold = 1
        success_count_threshold = 1

        header {
          name  = "Cache-Control"
          value = "no-cache"
        }
      }

      liveness_probe {
        transport = "HTTP"
        port      = 5000
        path      = "/health"

        header {
          name  = "Cache-Control"
          value = "no-cache"
        }

        initial_delay           = 5
        timeout                 = 2
        failure_count_threshold = 3
      }

      startup_probe {
        transport               = "TCP"
        port                    = 5000
        timeout                 = 5
        failure_count_threshold = 1
      }

      volume_mounts {
        name = azurerm_container_app_environment_storage.test.name
        path = "/tmp/testdata"
      }
    }

    volume {
      name         = azurerm_container_app_environment_storage.test.name
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.test.name
    }

    min_replicas = 1
    max_replicas = 4

    revision_suffix = "rev1"
  }

  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 5000
    transport                  = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 20
    }

    traffic_weight {
      revision_suffix = "rev1"
      percentage      = 80
    }
  }

  registry {
    server               = azurerm_container_registry.test.login_server
    username             = azurerm_container_registry.test.admin_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.test.admin_password
  }

  secret {
    name  = "rick"
    value = "morty"
  }

  dapr {
    app_id       = "acctest-cont-230929064613392944"
    app_port     = 5000
    app_protocol = "http"
  }

  tags = {
    foo     = "Bar"
    accTest = "1"
  }
}
