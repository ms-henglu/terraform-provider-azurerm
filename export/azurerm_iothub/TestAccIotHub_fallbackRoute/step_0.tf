
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025151988633"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-240119025151988633"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  fallback_route {
    source         = "DeviceMessages"
    endpoint_names = ["events"]
    enabled        = true
  }

  tags = {
    purpose = "testing"
  }
}
