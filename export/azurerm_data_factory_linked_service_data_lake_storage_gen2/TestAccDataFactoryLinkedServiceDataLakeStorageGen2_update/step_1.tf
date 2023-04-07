
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230407023248931390"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230407023248931390"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "test" {
  name                  = "acctestlssql230407023248931390"
  data_factory_id       = azurerm_data_factory.test.id
  service_principal_id  = data.azurerm_client_config.current.client_id
  service_principal_key = "testkey"
  tenant                = "11111111-1111-1111-1111-111111111111"
  url                   = "https://test.azure.com"
  annotations           = ["test1", "test2"]
  description           = "test description 2"

  parameters = {
    foo  = "test1"
    bar  = "test2"
    buzz = "test3"
  }

  additional_properties = {
    foo = "test1"
  }
}
