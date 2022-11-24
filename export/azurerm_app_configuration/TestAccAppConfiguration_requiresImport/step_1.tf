

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-221124181209323552"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf221124181209323552"
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
