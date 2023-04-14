
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230414021155424259"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230414021155424259"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name            = "acctestlsblob230414021155424259"
  data_factory_id = azurerm_data_factory.test.id
  url             = "foo"
  key             = "bar"
  annotations     = ["test1", "test2", "test3"]
  description     = "test description"

  parameters = {
    foO = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
