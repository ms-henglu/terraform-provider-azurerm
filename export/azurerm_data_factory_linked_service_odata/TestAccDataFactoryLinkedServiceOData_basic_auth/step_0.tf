
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759696349"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf231016033759696349"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odata" "test" {
  name            = "acctestlsodata231016033759696349"
  data_factory_id = azurerm_data_factory.test.id
  url             = "https://services.odata.org/v4/TripPinServiceRW/People"
  basic_authentication {
    username = "emma"
    password = "Ch4ngeM3!"
  }
}
