
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013532130071"
  location = "West Europe"
}
resource "azurerm_eventgrid_domain" "test" {
  name                = "acctestegdomain-221111013532130071"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_eventgrid_domain_topic" "test" {
  name                = "acctestegtopic-221111013532130071"
  domain_name         = azurerm_eventgrid_domain.test.name
  resource_group_name = azurerm_resource_group.test.name
}
