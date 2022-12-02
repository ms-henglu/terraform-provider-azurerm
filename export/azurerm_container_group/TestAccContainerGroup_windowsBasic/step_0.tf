
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035358364579"
  location = "West Europe"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-221202035358364579"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "Public"
  os_type             = "Windows"

  container {
    name   = "windowsservercore"
    image  = "mcr.microsoft.com/windows/servercore/iis:20210810-windowsservercore-ltsc2019"
    cpu    = "2.0"
    memory = "3.5"

    ports {
      port     = 80
      protocol = "TCP"
    }

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  tags = {
    environment = "Testing"
  }
}
