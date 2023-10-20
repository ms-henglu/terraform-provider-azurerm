


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020040437887181"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231020040437887181"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-231020040437887181"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription1"
  display_name        = "TestApiVersionSet1231020040437887181"
  versioning_scheme   = "Segment"
}


resource "azurerm_api_management_api_version_set" "import" {
  name                = azurerm_api_management_api_version_set.test.name
  resource_group_name = azurerm_api_management_api_version_set.test.resource_group_name
  api_management_name = azurerm_api_management_api_version_set.test.api_management_name
  description         = azurerm_api_management_api_version_set.test.description
  display_name        = azurerm_api_management_api_version_set.test.display_name
  versioning_scheme   = azurerm_api_management_api_version_set.test.versioning_scheme
}
