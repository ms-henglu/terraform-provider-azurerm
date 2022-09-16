
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220916011346797754"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220916011346797754"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odata" "test" {
  name            = "acctestlsodata220916011346797754"
  data_factory_id = azurerm_data_factory.test.id
  url             = "https://services.odata.org/v4/TripPinServiceRW/People"
  annotations     = ["test1", "test2"]
  description     = "Test Description 2"

  parameters = {
    foo  = "Test1"
    bar  = "Test2"
    buzz = "Test3"
  }

  additional_properties = {
    foo = "Test1"
  }
}
