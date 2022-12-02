
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-221202035908613203"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-221202035908613203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-221202035908613203"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-221202035908613203"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}
