
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-240311032307928971"
  location = "eastus"
  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240311032307928971"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  local_authentication_enabled = false

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}
  