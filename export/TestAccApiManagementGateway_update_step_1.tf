
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210910021044767909"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-210910021044767909"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-210910021044767909"
  api_management_id = azurerm_api_management.test.id
  description       = "updated description"

  location_data {
    name = "updated location"
  }
}
