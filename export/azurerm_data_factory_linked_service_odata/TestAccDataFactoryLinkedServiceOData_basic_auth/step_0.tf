
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221202035526143490"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf221202035526143490"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odata" "test" {
  name            = "acctestlsodata221202035526143490"
  data_factory_id = azurerm_data_factory.test.id
  url             = "https://services.odata.org/v4/TripPinServiceRW/People"
  basic_authentication {
    username = "emma"
    password = "Ch4ngeM3!"
  }
}
