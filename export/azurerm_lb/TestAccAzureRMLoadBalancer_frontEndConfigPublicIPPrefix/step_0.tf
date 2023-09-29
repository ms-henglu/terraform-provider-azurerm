
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230929065130770730"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "test-ip-prefix-230929065130770730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 31
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-230929065130770730"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                = "prefix-230929065130770730"
    public_ip_prefix_id = azurerm_public_ip_prefix.test.id
  }
}
