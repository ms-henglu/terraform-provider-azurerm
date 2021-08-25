
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044619463826"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-210825044619463826"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "public"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "microsoft/aci-helloworld:latest"
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

  container {
    name   = "sidecar"
    image  = "microsoft/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "0.5"
  }

  tags = {
    environment = "Testing"
  }
}
