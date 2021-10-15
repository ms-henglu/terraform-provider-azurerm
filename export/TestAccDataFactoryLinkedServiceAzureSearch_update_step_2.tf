

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211015014528488281"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf211015014528488281"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice211015014528488281"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_data_factory_linked_service_azure_search" "test" {
  name               = "acctestlssearch211015014528488281"
  data_factory_id    = azurerm_data_factory.test.id
  url                = join("", ["https://", azurerm_search_service.test.name, ".search.windows.net"])
  search_service_key = azurerm_search_service.test.primary_key

  annotations = ["test1", "test2", "test3"]
  description = "test description"

  parameters = {
    foo = "test1"
    bar = "test2"
  }

  additional_properties = {
    foo = "test1"
    bar = "test2"
  }
}
