
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230915023022273410"
  location = "West US"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-230915023022273410"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_search_service" "test2" {
  name                = "acctestsearchacc2-230915023022273410"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                                         = "acctestcogacc-230915023022273410"
  location                                     = azurerm_resource_group.test.location
  resource_group_name                          = azurerm_resource_group.test.name
  kind                                         = "TextAnalytics"
  sku_name                                     = "F0"
  custom_question_answering_search_service_id  = azurerm_search_service.test2.id
  custom_question_answering_search_service_key = azurerm_search_service.test2.primary_key
}
