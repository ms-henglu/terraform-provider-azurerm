
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117230656486327"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroupemptyshared-221117230656486327"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "None"
  os_type             = "Linux"
  restart_policy      = "Never"

  init_container {
    name     = "init"
    image    = "busybox"
    commands = ["echo", "hello from init"]
  }

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "1"
    memory = "1.5"

    commands = ["echo", "hello from ubuntu"]
  }
}
