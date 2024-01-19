


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407427506"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407427506"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240119024407427506"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}


resource "azurerm_api_management_api_schema" "test" {
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management_api.test.api_management_name
  resource_group_name = azurerm_api_management_api.test.resource_group_name
  schema_id           = "acctestSchema240119024407427506"
  content_type        = "application/vnd.ms-azure-apim.xsd+xml"
  value               = file("testdata/api_management_api_schema.xml")
}


resource "azurerm_api_management_api_schema" "import" {
  api_name            = azurerm_api_management_api_schema.test.api_name
  api_management_name = azurerm_api_management_api_schema.test.api_management_name
  resource_group_name = azurerm_api_management_api_schema.test.resource_group_name
  schema_id           = azurerm_api_management_api_schema.test.schema_id
  content_type        = azurerm_api_management_api_schema.test.content_type
  value               = azurerm_api_management_api_schema.test.value
}
