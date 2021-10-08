
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044411474376"
  location = "West Europe"
}
resource "azurerm_eventgrid_domain" "test" {
  name                = "acctestegdomain-211008044411474376"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_eventgrid_domain_topic" "test" {
  name                = "acctestegtopic-211008044411474376"
  domain_name         = azurerm_eventgrid_domain.test.name
  resource_group_name = azurerm_resource_group.test.name
}
