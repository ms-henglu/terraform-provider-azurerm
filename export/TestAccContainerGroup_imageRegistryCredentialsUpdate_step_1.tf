
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825025634815822"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-210825025634815822"
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
  }

  image_registry_credential {
    server   = "hub.docker.com"
    username = "updatedusername"
    password = "updatedpassword"
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
