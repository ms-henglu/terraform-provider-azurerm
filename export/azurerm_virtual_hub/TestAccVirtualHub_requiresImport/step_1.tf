


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431053664"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-231016034431053664"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_virtual_hub" "test" {
  name                = "acctestVHUB-231016034431053664"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}


resource "azurerm_virtual_hub" "import" {
  name                = azurerm_virtual_hub.test.name
  location            = azurerm_virtual_hub.test.location
  resource_group_name = azurerm_virtual_hub.test.resource_group_name
  virtual_wan_id      = azurerm_virtual_hub.test.virtual_wan_id
  address_prefix      = azurerm_virtual_hub.test.address_prefix
}
