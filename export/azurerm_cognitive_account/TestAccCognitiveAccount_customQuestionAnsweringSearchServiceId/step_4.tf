
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-240119024621914930"
  location = "West US"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-240119024621914930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_search_service" "test2" {
  name                = "acctestsearchacc2-240119024621914930"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-240119024621914930"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "TextAnalytics"
  sku_name            = "F0"
}
