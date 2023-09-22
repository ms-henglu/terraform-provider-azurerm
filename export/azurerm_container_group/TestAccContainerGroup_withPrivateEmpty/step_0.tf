
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-containergroup-230922053854810489"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-230922053854810489"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  dns_name_label      = "jerome-aci-label"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8000
      protocol = "TCP"
    }

    secure_environment_variables = {
      PRIVATE_EMPTY = ""
      PRIVATE_VALUE = "test"
    }

    environment_variables = {
      PUBLIC_EMPTY = ""
      PUBLIC_VALUE = "test"
    }
  }
}
