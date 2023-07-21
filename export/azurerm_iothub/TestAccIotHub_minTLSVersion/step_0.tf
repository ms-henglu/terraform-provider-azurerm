
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-iothub-230721015302239254"
  location = "eastus"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230721015302239254"
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
