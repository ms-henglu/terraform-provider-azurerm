
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-220429065238616429"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-220429065238616429"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                                        = "acctestcogacc-220429065238616429"
  location                                    = azurerm_resource_group.test.location
  resource_group_name                         = azurerm_resource_group.test.name
  kind                                        = "TextAnalytics"
  sku_name                                    = "F0"
  custom_question_answering_search_service_id = azurerm_search_service.test.id
}
