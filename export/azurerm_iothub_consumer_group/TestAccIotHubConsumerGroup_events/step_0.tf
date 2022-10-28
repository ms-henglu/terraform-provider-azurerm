
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172252035096"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-221028172252035096"
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
