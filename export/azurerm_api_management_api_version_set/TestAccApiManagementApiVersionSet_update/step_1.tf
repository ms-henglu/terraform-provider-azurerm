

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707003233572223"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230707003233572223"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-230707003233572223"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription2"
  display_name        = "TestApiVersionSet2230707003233572223"
  versioning_scheme   = "Segment"
}
