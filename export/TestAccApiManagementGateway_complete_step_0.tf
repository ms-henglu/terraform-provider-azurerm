
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324175907121635"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220324175907121635"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-220324175907121635"
  api_management_id = azurerm_api_management.test.id
  description       = "test description"

  location_data {
    name     = "test location"
    city     = "test city"
    district = "test district"
    region   = "test region"
  }
}
