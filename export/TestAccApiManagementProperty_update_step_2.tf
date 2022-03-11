
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311041959924502"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220311041959924502"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}

resource "azurerm_api_management_property" "test" {
  name                = "acctestAMProperty-220311041959924502"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  display_name        = "TestProperty2220311041959924502"
  value               = "Test Value2"
  secret              = true
  tags                = ["tag3", "tag4"]
}
