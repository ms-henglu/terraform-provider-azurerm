
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122643895281"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroupemptyshared-240315122643895281"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "None"
  os_type             = "Linux"
  restart_policy      = "Never"

  init_container {
    name     = "init"
    image    = "busybox"
    commands = ["echo", "hello from init"]
    secure_environment_variables = {
      PASSWORD = "something_very_secure_for_init"
    }
  }

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "1"
    memory = "1.5"

    commands = ["echo", "hello from ubuntu"]
    secure_environment_variables = {
      PASSWORD = "something_very_secure"
    }
  }
}
