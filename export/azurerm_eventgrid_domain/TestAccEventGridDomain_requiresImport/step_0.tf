
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112034402010328"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-240112034402010328"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
