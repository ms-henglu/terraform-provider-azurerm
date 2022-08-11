
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-220811052946111478"
  location = "West US"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-220811052946111478"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_search_service" "test2" {
  name                = "acctestsearchacc2-220811052946111478"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                                         = "acctestcogacc-220811052946111478"
  location                                     = azurerm_resource_group.test.location
  resource_group_name                          = azurerm_resource_group.test.name
  kind                                         = "TextAnalytics"
  sku_name                                     = "F0"
  custom_question_answering_search_service_id  = azurerm_search_service.test2.id
  custom_question_answering_search_service_key = azurerm_search_service.test2.primary_key
}
