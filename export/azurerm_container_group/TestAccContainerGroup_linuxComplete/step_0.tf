
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064631504959"
  location = "northeurope"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-230929064631504959"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa230929064631504959"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "test" {
  name = "acctestss-230929064631504959"

  storage_account_name = azurerm_storage_account.test.name

  quota = 50
}

resource "azurerm_container_group" "test" {
  name                        = "acctestcontainergroup-230929064631504959"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  ip_address_type             = "Public"
  dns_name_label              = "acctestcontainergroup-230929064631504959"
  dns_name_label_reuse_policy = "Unsecure"
  os_type                     = "Linux"
  restart_policy              = "OnFailure"

  container {
    name   = "hf"
    image  = "seanmckenna/aci-hellofiles"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    gpu {
      count = 1
      sku   = "K80"
    }

    cpu_limit    = "1"
    memory_limit = "1.5"

    gpu_limit {
      count = 1
      sku   = "K80"
    }


    volume {
      name       = "logs"
      mount_path = "/aci/logs"
      read_only  = false
      share_name = azurerm_storage_share.test.name

      storage_account_name = azurerm_storage_account.test.name
      storage_account_key  = azurerm_storage_account.test.primary_access_key
    }

    environment_variables = {
      foo  = "bar"
      foo1 = "bar1"
    }

    secure_environment_variables = {
      secureFoo  = "secureBar"
      secureFoo1 = "secureBar1"
    }

    readiness_probe {
      exec                  = ["cat", "/tmp/healthy"]
      initial_delay_seconds = 1
      period_seconds        = 1
      failure_threshold     = 1
      success_threshold     = 1
      timeout_seconds       = 1
    }

    liveness_probe {
      http_get {
        path   = "/"
        port   = 443
        scheme = "Http"
        http_headers = {
          h1 = "v1"
          h2 = "v2"
        }
      }

      initial_delay_seconds = 1
      period_seconds        = 1
      failure_threshold     = 1
      success_threshold     = 1
      timeout_seconds       = 1
    }

    commands = ["/bin/bash", "-c", "ls"]
  }

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.test.workspace_id
      workspace_key = azurerm_log_analytics_workspace.test.primary_shared_key
      log_type      = "ContainerInsights"

      metadata = {
        node-name = "acctestContainerGroup"
      }
    }
  }

  tags = {
    environment = "Testing"
  }
}
