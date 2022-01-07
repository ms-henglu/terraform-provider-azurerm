

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220107033512772433"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220107033512772433"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_named_value" "test" {
  name                = "acctestAMProperty-220107033512772433"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "TestProperty2220107033512772433"
  value               = "Test Value2"
  secret              = true
  tags                = ["tag3", "tag4"]
}
