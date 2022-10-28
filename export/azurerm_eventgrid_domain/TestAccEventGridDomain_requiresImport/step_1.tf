

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172133624121"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-221028172133624121"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_eventgrid_domain" "import" {
  name                = azurerm_eventgrid_domain.test.name
  location            = azurerm_eventgrid_domain.test.location
  resource_group_name = azurerm_eventgrid_domain.test.resource_group_name
}
