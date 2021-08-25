
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-210825044449693710"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf210825044449693710"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  tags = {
    environment = "development"
  }
}
