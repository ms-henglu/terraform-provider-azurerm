
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221203929274537"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                   = "acctestappinsights-221221203929274537"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  application_type       = "web"
  internet_query_enabled = true
}
