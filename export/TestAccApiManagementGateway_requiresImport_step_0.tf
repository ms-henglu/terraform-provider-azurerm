
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220121044153460909"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220121044153460909"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_gateway" "test" {
  name              = "acctestAMGateway-220121044153460909"
  api_management_id = azurerm_api_management.test.id

  location_data {
    name = "test"
  }
}
