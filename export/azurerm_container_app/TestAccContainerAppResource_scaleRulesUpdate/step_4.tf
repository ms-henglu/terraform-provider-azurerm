

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-CAE-231020040801182287"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "acctestLAW-231020040801182287"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_container_app_environment" "test" {
  name                = "acctest-CAEnv231020040801182287"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_container_app" "test" {
  name                         = "acctest-capp-231020040801182287"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = azurerm_container_app_environment.test.id
  revision_mode                = "Single"

  secret {
    name  = "queue-auth-secret"
    value = "VGhpcyBJcyBOb3QgQSBHb29kIFBhc3N3b3JkCg=="
  }

  template {
    container {
      name   = "acctest-cont-231020040801182287"
      image  = "jackofallops/azure-containerapps-python-acctest:v0.0.1"
      cpu    = 0.25
      memory = "0.5Gi"
    }

    azure_queue_scale_rule {
      name         = "azq-1"
      queue_name   = "foo"
      queue_length = 10

      authentication {
        secret_name       = "queue-auth-secret"
        trigger_parameter = "password"
      }
    }

    azure_queue_scale_rule {
      name         = "azq-2"
      queue_name   = "bar"
      queue_length = 20

      authentication {
        secret_name       = "queue-auth-secret"
        trigger_parameter = "another_password"
      }
    }

    custom_scale_rule {
      name             = "csr-1"
      custom_rule_type = "rabbitmq"

      metadata = {
        foo = "bar"
      }

      authentication {
        secret_name       = "queue-auth-secret"
        trigger_parameter = "password"
      }
    }

    http_scale_rule {
      name                = "http-1"
      concurrent_requests = "200"

      authentication {
        secret_name       = "queue-auth-secret"
        trigger_parameter = "password"
      }
    }

    tcp_scale_rule {
      name                = "tcp-1"
      concurrent_requests = "1000"

      authentication {
        secret_name       = "queue-auth-secret"
        trigger_parameter = "password"
      }
    }
  }
}
