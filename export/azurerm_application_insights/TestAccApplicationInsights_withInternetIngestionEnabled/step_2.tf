
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022829151920"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                       = "acctestappinsights-230915022829151920"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  application_type           = "web"
  internet_ingestion_enabled = false
}
