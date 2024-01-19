
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024742765083"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-240119024742765083"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"
    liveness_probe {
      exec = ["cat", "/tmp/healthy"]
    }
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Testing"
  }
}
