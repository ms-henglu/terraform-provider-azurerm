
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230825024753480422"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn-230825024753480422"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub-230825024753480422"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-230825024753480422"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"

  frontend_ip_configuration {
    name                          = "Internal"
    private_ip_address_allocation = "Dynamic"
    private_ip_address            = ""
    subnet_id                     = azurerm_subnet.test.id
  }
}
