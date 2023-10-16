

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033913516095"
  location = "West Europe"
}
resource "azurerm_eventgrid_domain" "test" {
  name                = "acctestegdomain-231016033913516095"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_eventgrid_domain_topic" "test" {
  name                = "acctestegtopic-231016033913516095"
  domain_name         = azurerm_eventgrid_domain.test.name
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_eventgrid_domain_topic" "import" {
  name                = azurerm_eventgrid_domain_topic.test.name
  domain_name         = azurerm_eventgrid_domain_topic.test.domain_name
  resource_group_name = azurerm_eventgrid_domain_topic.test.resource_group_name
}
