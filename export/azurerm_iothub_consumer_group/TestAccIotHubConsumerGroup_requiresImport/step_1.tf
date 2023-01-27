

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127045538366209"
  location = "West Europe"
}

resource "azurerm_iothub" "test" {
  name                = "acctestIoTHub-230127045538366209"
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


resource "azurerm_iothub_consumer_group" "import" {
  name                   = azurerm_iothub_consumer_group.test.name
  iothub_name            = azurerm_iothub_consumer_group.test.iothub_name
  eventhub_endpoint_name = azurerm_iothub_consumer_group.test.eventhub_endpoint_name
  resource_group_name    = azurerm_iothub_consumer_group.test.resource_group_name
}
