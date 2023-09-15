

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022812178026"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230915022812178026"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}


resource "azurerm_api_management" "import" {
  name                = azurerm_api_management.test.name
  location            = azurerm_api_management.test.location
  resource_group_name = azurerm_api_management.test.resource_group_name
  publisher_name      = azurerm_api_management.test.publisher_name
  publisher_email     = azurerm_api_management.test.publisher_email

  sku_name = "Developer_1"
}
