
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-231016033517418756"
  location = "West US"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchacc-231016033517418756"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_search_service" "test2" {
  name                = "acctestsearchacc2-231016033517418756"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}

resource "azurerm_cognitive_account" "test" {
  name                = "acctestcogacc-231016033517418756"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "TextAnalytics"
  sku_name            = "F0"
}
