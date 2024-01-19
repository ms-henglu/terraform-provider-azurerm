
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-240119024426251456"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-240119024426251456"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "phone"
}
