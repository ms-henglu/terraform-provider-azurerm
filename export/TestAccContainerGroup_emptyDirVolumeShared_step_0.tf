
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211001053557518075"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroupemptyshared-211001053557518075"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_address_type     = "public"
  dns_name_label      = "acctestcontainergroup-211001053557518075"
  os_type             = "Linux"
  restart_policy      = "Never"

  container {
    name     = "writer"
    image    = "ubuntu:20.04"
    cpu      = "1"
    memory   = "1.5"
    commands = ["touch", "/sharedempty/file.txt"]

    # Dummy port not used, workaround for https://github.com/hashicorp/terraform-provider-azurerm/issues/1697
    ports {
      port     = 80
      protocol = "TCP"
    }

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
