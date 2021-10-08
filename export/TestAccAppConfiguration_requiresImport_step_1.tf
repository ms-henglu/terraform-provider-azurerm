

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211008044026934957"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf211008044026934957"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_app_configuration" "import" {
  name                = azurerm_app_configuration.test.name
  resource_group_name = azurerm_app_configuration.test.resource_group_name
  location            = azurerm_app_configuration.test.location
  sku                 = azurerm_app_configuration.test.sku
}
