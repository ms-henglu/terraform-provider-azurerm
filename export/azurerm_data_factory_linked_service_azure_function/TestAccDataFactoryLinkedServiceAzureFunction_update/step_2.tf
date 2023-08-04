
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230804025818544739"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230804025818544739"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name            = "acctestlsblob230804025818544739"
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
