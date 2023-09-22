
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230922060727409644"
  location = "West US"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-230922060727409644"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                                         = "acctestcogacc-230922060727409644"
  location                                     = azurerm_resource_group.test.location
  resource_group_name                          = azurerm_resource_group.test.name
  kind                                         = "TextAnalytics"
  sku_name                                     = "F0"
  custom_question_answering_search_service_id  = azurerm_search_service.test.id
  custom_question_answering_search_service_key = azurerm_search_service.test.primary_key
}
