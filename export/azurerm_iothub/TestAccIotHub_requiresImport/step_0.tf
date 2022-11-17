
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-221117231012564310"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221117231012564310"
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
