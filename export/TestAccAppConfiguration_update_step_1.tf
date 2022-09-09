
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220909033818337927"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                  = "testaccappconf220909033818337927"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  public_network_access = "Disabled"
  sku                   = "standard"

  tags = {
    Environment = "Production"
  }
}
