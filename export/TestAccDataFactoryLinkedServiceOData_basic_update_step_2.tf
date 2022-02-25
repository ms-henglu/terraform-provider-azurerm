
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220225034258415646"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220225034258415646"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odata" "test" {
  name                = "acctestlsodata220225034258415646"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = "https://services.odata.org/v4/TripPinServiceRW/People"
  annotations         = ["test1", "test2"]
  description         = "Test Description 2"

  parameters = {
    foo  = "Test1"
    bar  = "Test2"
    buzz = "Test3"
  }

  additional_properties = {
    foo = "Test1"
  }
}
