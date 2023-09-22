
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060849027170"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-230922060849027170"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  dns_name_label      = "acctestcontainergroup-230922060849027170"
  os_type             = "Linux"
  restart_policy      = "OnFailure"

  container {
    name   = "hf"
    image  = "seanmckenna/aci-hellofiles"
    cpu    = "1"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    volume {
      name       = "logs"
      mount_path = "/aci/logs"
      read_only  = false

      git_repo {
        url       = "https://github.com/Azure-Samples/aci-helloworld"
        directory = "app"
        revision  = "d5ccfce"
      }
    }

    environment_variables = {
      foo  = "bar"
      foo1 = "bar1"
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
      }

      initial_delay_seconds = 1
      period_seconds        = 1
      failure_threshold     = 1
      success_threshold     = 1
      timeout_seconds       = 1
    }

    commands = ["/bin/bash", "-c", "ls"]
  }
}
