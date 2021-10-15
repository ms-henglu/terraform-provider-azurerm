
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014444955356"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-211015014444955356"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_address_type     = "public"
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
  }

  tags = {
    environment = "Testing"
  }
}
