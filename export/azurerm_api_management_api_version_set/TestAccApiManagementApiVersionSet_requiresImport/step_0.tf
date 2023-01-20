

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120054209008317"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230120054209008317"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_api_version_set" "test" {
  name                = "acctestAMAVS-230120054209008317"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  description         = "TestDescription1"
  display_name        = "TestApiVersionSet1230120054209008317"
  versioning_scheme   = "Segment"
}
