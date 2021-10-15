
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014127481402"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014127481402"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_odata" "test" {
  name                = "acctestlsodata211015014127481402"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  url                 = "https://services.odata.org/v4/TripPinServiceRW/People"
  basic_authentication {
    username = "emma"
    password = "Ch4ngeM3!"
  }
}
