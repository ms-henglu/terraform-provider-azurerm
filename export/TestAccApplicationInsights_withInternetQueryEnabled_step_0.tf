
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044205193590"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                   = "acctestappinsights-220121044205193590"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  application_type       = "web"
  internet_query_enabled = true
}
