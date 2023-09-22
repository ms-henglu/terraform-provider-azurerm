
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-230922061258290483"
  location = "eastus"
  tags = {
    purpose = "testing"
  }
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230922061258290483"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  local_authentication_enabled = true

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}
  