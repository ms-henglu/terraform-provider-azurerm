

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221203917782351"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221221203917782351"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_tag" "test" {
  api_management_id = azurerm_api_management.test.id
  name              = "acctest-Op-Tag-221221203917782351"
}
