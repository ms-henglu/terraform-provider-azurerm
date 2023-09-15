


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230915023301705607"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230915023301705607"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230915023301705607"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_data_factory_linked_service_azure_search" "test" {
  name               = "acctestlssearch230915023301705607"
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
