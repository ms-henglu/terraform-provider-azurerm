

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031404420188"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-210825031404420188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_named_value" "test" {
  name                = "acctestAMProperty-210825031404420188"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "TestProperty2210825031404420188"
  value               = "Test Value2"
  secret              = true
  tags                = ["tag3", "tag4"]
}
