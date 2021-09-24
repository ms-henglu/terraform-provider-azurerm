

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924010639360737"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-210924010639360737"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-210924010639360737"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription2"
  display_name        = "TestApiVersionSet2210924010639360737"
  versioning_scheme   = "Segment"
}
