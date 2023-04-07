

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230407024036146527"
  location = "West Europe"
}

resource "azurerm_search_service" "test" {
  name                = "acctestsearchservice230407024036146527"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_search_service" "import" {
  name                = azurerm_search_service.test.name
  resource_group_name = azurerm_search_service.test.resource_group_name
  location            = azurerm_search_service.test.location
  sku                 = azurerm_search_service.test.sku

  tags = {
    environment = "staging"
  }
}
