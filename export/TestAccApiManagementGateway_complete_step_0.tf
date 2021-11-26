
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211126030844053135"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-211126030844053135"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-211126030844053135"
  api_management_id = azurerm_api_management.test.id
  description       = "test description"

  location_data {
    name     = "test location"
    city     = "test city"
    district = "test district"
    region   = "test region"
  }
}
