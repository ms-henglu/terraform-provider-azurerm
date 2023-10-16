
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034057247496"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-231016034057247496"
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

resource "azurerm_iothub_consumer_group" "test" {
  name                   = "test"
  iothub_name            = azurerm_iothub.test.name
  eventhub_endpoint_name = "events"
  resource_group_name    = azurerm_resource_group.test.name
}
