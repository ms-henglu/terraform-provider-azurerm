


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220623223016339088"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-220623223016339088"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-220623223016339088"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}


resource "azurerm_api_management_api_release" "test" {
  name   = "acctest-ApiRelease-220623223016339088"
  api_id = azurerm_api_management_api.test.id
  notes  = "Release 1.0"
}
