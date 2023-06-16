
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230616074947260149"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230616074947260149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-230616074947260149"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-230616074947260149"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}
