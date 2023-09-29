

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929065041030420"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230929065041030420"
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


resource "azurerm_iothub_shared_access_policy" "test" {
  name                = "acctestSharedAccessPolicy"
  resource_group_name = azurerm_resource_group.test.name
  iothub_name         = azurerm_iothub.test.name
  service_connect     = true
}
