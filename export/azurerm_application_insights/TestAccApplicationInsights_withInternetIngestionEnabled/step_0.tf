
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032616544506"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                       = "acctestappinsights-230630032616544506"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  application_type           = "web"
  internet_ingestion_enabled = true
}
