
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527719223"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-240119025527719223"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "gw47n6tfyo6ibuqvj7bsxys3x3g7spamv3kzbggn6wst43laqgv9lth9xwmzhxt"
}
