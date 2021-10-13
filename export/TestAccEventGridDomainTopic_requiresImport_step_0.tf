
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013071844938576"
  location = "West Europe"
}
resource "azurerm_eventgrid_domain" "test" {
  name                = "acctestegdomain-211013071844938576"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_eventgrid_domain_topic" "test" {
  name                = "acctestegtopic-211013071844938576"
  domain_name         = azurerm_eventgrid_domain.test.name
  resource_group_name = azurerm_resource_group.test.name
}
