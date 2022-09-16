
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011556369385"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220916011556369385"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}
