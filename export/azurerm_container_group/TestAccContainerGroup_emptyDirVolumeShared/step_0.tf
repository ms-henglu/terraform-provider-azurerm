
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071509677182"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroupemptyshared-231218071509677182"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "None"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name     = "writer"
    image    = "ubuntu:20.04"
    cpu      = "1"
    memory   = "1.5"
    commands = ["touch", "/sharedempty/file.txt"]

    volume {
      name       = "logs"
      mount_path = "/sharedempty"
      read_only  = false
      empty_dir  = true
    }
  }

  container {
    name   = "reader"
    image  = "ubuntu:20.04"
    cpu    = "1"
    memory = "1.5"

    volume {
      name       = "logs"
      mount_path = "/sharedempty"
      read_only  = false
      empty_dir  = true
    }

    commands = ["/bin/bash", "-c", "timeout 30 watch --interval 1 --errexit \"! cat /sharedempty/file.txt\""]
  }
}
