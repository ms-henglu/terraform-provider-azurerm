
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024250506689"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-211210024250506689"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
  min_api_version     = "2020-12-01"
}
