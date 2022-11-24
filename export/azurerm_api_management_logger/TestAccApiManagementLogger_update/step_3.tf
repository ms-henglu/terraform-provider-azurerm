
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181202645469"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-221124181202645469"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "other"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221124181202645469"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}

resource "azurerm_api_management_logger" "test" {
  name                = "acctestapimnglogger-221124181202645469"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  description         = "Logger from Terraform update test"
  buffered            = true
  resource_id         = azurerm_application_insights.test.id

  application_insights {
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
}
