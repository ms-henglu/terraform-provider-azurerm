

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220623223303906595"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf220623223303906595"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice220623223303906595"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_data_factory_linked_service_azure_search" "test" {
  name               = "acctestlssearch220623223303906595"
  data_factory_id    = azurerm_data_factory.test.id
  url                = join("", ["https://", azurerm_search_service.test.name, ".search.windows.net"])
  search_service_key = azurerm_search_service.test.primary_key
}
