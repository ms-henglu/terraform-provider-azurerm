
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-231218072018578663"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-231218072018578663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "test1" {
  name                = "another-test-ip-231218072018578663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-231218072018578663"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "one-231218072018578663"
    public_ip_address_id = azurerm_public_ip.test.id
  }

  frontend_ip_configuration {
    name                 = "two-231218072018578663"
    public_ip_address_id = azurerm_public_ip.test1.id
  }
}
