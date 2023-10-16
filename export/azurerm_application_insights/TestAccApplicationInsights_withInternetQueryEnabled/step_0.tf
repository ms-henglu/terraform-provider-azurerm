
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033318112444"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                   = "acctestappinsights-231016033318112444"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  application_type       = "web"
  internet_query_enabled = true
}
