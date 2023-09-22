

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922061636825492"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-230922061636825492"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_public_ip_prefix" "import" {
  name                = azurerm_public_ip_prefix.test.name
  location            = azurerm_public_ip_prefix.test.location
  resource_group_name = azurerm_public_ip_prefix.test.resource_group_name
}
