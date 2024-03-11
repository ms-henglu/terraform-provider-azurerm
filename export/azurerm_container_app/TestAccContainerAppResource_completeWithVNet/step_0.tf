


provider "azurerm" {
  features {}
}




resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-240311031653048279"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-240311031653048279"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240311031653048279"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "control" {
  name                 = "control-plane"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/23"]
}



resource "azurerm_container_app_environment" "test" {
  name                       = "acctest-CAEnv240311031653048279"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id

  infrastructure_subnet_id = azurerm_subnet.control.id

  internal_load_balancer_enabled = true

  tags = {
    Foo    = "Bar"
    secret = "sauce"
  }
}

resource "azurerm_container_registry" "test" {
  name                = "testacccr240311031653048279"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
  admin_enabled       = true

  network_rule_set = []
}

resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accttiz8n"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_share" "test" {
  name                 = "testsharetiz8n"
  storage_account_name = azurerm_storage_account.test.name
  quota                = 1
}

resource "azurerm_container_app_environment_storage" "test" {
  name                         = "testacc-caes-240311031653048279"
  container_app_environment_id = azurerm_container_app_environment.test.id
  account_name                 = azurerm_storage_account.test.name
  access_key                   = azurerm_storage_account.test.primary_access_key
  share_name                   = azurerm_storage_share.test.name
  access_mode                  = "ReadWrite"
}


resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-240311031653048279"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  template {
    container {
      name   = "acctest-cont-240311031653048279"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"

      readiness_probe {
        transport = "HTTP"
        port      = 5000
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
        failure_count_threshold = 1
      }

      startup_probe {
        transport = "TCP"
        port      = 5000
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

    min_replicas = 2
    max_replicas = 3

    revision_suffix = "rev1"
  }

  ingress {
    allow_insecure_connections = true
    target_port                = 5000
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
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

  tags = {
    foo     = "Bar"
    accTest = "1"
  }
}
