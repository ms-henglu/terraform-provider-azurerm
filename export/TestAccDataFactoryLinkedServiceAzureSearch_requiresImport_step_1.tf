


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211217075141449069"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211217075141449069"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice211217075141449069"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_data_factory_linked_service_azure_search" "test" {
  name               = "acctestlssearch211217075141449069"
  data_factory_id    = azurerm_data_factory.test.id
  url                = join("", ["https://", azurerm_search_service.test.name, ".search.windows.net"])
  search_service_key = azurerm_search_service.test.primary_key
}


resource "azurerm_data_factory_linked_service_azure_search" "import" {
  name               = azurerm_data_factory_linked_service_azure_search.test.name
  data_factory_id    = azurerm_data_factory_linked_service_azure_search.test.data_factory_id
  url                = azurerm_data_factory_linked_service_azure_search.test.url
  search_service_key = azurerm_data_factory_linked_service_azure_search.test.search_service_key
}
