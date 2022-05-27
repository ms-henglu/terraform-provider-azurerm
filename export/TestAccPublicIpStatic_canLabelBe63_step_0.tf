
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034514211258"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-220527034514211258"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "pbjebvlq13xwzzwxk08zzxfj2seijonfvdfi46rbz3nqg72tw1mpsjl1khzx2d7"
}
