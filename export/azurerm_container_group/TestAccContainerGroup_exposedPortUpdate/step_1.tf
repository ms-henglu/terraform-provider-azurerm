
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064631504289"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-230929064631504289"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  exposed_port {
    port = 80
  }

  exposed_port {
    port     = 5443
    protocol = "UDP"
  }

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port = 80
    }

    ports {
      port     = 5443
      protocol = "UDP"
    }
  }

  tags = {
    environment = "Testing"
  }
}
