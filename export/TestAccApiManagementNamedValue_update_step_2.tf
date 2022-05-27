

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527023813451929"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220527023813451929"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_named_value" "test" {
  name                = "acctestAMProperty-220527023813451929"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "TestProperty2220527023813451929"
  value               = "Test Value2"
  secret              = true
  tags                = ["tag3", "tag4"]
}
