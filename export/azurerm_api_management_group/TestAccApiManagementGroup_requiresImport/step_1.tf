

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512003341177188"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230512003341177188"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_group" "test" {
  name                = "acctestAMGroup-230512003341177188"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Test Group"
}


resource "azurerm_api_management_group" "import" {
  name                = azurerm_api_management_group.test.name
  resource_group_name = azurerm_api_management_group.test.resource_group_name
  api_management_name = azurerm_api_management_group.test.api_management_name
  display_name        = azurerm_api_management_group.test.display_name
}
