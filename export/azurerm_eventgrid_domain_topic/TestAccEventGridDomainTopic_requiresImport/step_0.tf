
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027127623"
  location = "West Europe"
}
resource "azurerm_eventgrid_domain" "test" {
  name                = "acctestegdomain-240119025027127623"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_eventgrid_domain_topic" "test" {
  name                = "acctestegtopic-240119025027127623"
  domain_name         = azurerm_eventgrid_domain.test.name
  resource_group_name = azurerm_resource_group.test.name
}
