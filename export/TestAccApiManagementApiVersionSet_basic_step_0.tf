

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105035510702709"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-211105035510702709"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-211105035510702709"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription1"
  display_name        = "TestApiVersionSet1211105035510702709"
  versioning_scheme   = "Segment"
}
