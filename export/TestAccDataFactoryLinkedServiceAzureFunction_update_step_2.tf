
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220916011346787415"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220916011346787415"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name            = "acctestlsblob220916011346787415"
  data_factory_id = azurerm_data_factory.test.id

  url         = "foo"
  key         = "bar"
  annotations = ["Test1", "Test2"]
  description = "test description 2"

  parameters = {
    foo  = "Test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }
}
