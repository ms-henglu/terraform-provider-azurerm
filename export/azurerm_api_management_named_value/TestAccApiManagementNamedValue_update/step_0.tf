

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106034052100968"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230106034052100968"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_named_value" "test" {
  name                = "acctestAMProperty-230106034052100968"
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  display_name        = "TestProperty230106034052100968"
  value               = "Test Value"
  tags                = ["tag1", "tag2"]
}
