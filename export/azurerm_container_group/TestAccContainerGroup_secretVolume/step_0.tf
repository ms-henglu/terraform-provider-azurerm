
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224211686165"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-240112224211686165"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"
    ports {
      port     = 80
      protocol = "TCP"
    }

    volume {
      name       = "config"
      mount_path = "/var/config"

      secret = {
        mysecret1 = "TXkgZmlyc3Qgc2VjcmV0IEZPTwo="
        mysecret2 = "TXkgc2Vjb25kIHNlY3JldCBCQVIK"
      }
    }
  }

  tags = {
    environment = "Testing"
  }
}
