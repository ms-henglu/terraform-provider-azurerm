
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-220826002832172797"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220826002832172797"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}
