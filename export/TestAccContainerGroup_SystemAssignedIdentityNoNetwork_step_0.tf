
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044333424204"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-220121044333424204"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "None"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "ubuntu:20.04"
    cpu    = "0.5"
    memory = "0.5"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "Testing"
  }
}
