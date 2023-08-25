
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024002813305"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                       = "acctestappinsights-230825024002813305"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  application_type           = "web"
  internet_ingestion_enabled = false
}
