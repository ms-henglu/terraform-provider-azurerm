
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-221221204452181233"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "test-ip-prefix-221221204452181233"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  prefix_length       = 31
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-221221204452181233"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                = "prefix-221221204452181233"
    public_ip_prefix_id = azurerm_public_ip_prefix.test.id
  }
}
