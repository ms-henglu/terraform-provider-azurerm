

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117230444361112"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221117230444361112"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-221117230444361112"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription2"
  display_name        = "TestApiVersionSet2221117230444361112"
  versioning_scheme   = "Segment"
}
