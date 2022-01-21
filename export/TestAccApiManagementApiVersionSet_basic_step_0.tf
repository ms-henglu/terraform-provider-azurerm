

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044153461505"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220121044153461505"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-220121044153461505"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription1"
  display_name        = "TestApiVersionSet1220121044153461505"
  versioning_scheme   = "Segment"
}
