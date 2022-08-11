
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-220811053401902934"
  location = "eastus"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-220811053401902934"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  min_tls_version = "1.2"

  sku {
    name     = "B1"
    capacity = "1"
  }

  tags = {
    purpose = "testing"
  }
}
