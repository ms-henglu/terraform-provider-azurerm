

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221203917733801"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221221203917733801"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-221221203917733801"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  api_type            = "graphql"
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}
