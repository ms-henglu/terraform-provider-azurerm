
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014728973091"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice211015014728973091"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "staging"
  }
}
