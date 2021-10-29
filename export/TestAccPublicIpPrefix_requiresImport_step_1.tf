

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015948860381"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-211029015948860381"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_public_ip_prefix" "import" {
  name                = azurerm_public_ip_prefix.test.name
  location            = azurerm_public_ip_prefix.test.location
  resource_group_name = azurerm_public_ip_prefix.test.resource_group_name
}
