
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-220506005504518749"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-220506005504518749"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_search_service" "test2" {
  name                = "acctestsearchacc2-220506005504518749"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                                        = "acctestcogacc-220506005504518749"
  location                                    = azurerm_resource_group.test.location
  resource_group_name                         = azurerm_resource_group.test.name
  kind                                        = "TextAnalytics"
  sku_name                                    = "F0"
  custom_question_answering_search_service_id = azurerm_search_service.test2.id
}
