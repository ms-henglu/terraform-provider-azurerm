


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040437870133"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231020040437870133"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-231020040437870133"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}


resource "azurerm_api_management_api" "revision" {
  name                 = "acctestRevision-231020040437870133"
  resource_group_name  = azurerm_resource_group.test.name
  api_management_name  = azurerm_api_management.test.name
  revision             = "18"
  source_api_id        = azurerm_api_management_api.test.id
  revision_description = "Creating a Revision of an existing API"
}
