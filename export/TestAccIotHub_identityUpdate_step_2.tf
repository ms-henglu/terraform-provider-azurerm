
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-220712042358217612"
  location = "West Europe"
}
resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220712042358217612"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku {
    name     = "B1"
    capacity = "1"
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    purpose = "testing"
  }
}
