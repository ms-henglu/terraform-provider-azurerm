

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627122353143999"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220627122353143999"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-220627122353143999"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription1"
  display_name        = "TestApiVersionSet1220627122353143999"
  versioning_scheme   = "Segment"
}
