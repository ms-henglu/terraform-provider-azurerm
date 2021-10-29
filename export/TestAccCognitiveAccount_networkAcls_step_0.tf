

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-211029015322163822"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet211029015322163822"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test_a" {
  name                 = "acctestsubneta211029015322163822"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.CognitiveServices"]
}

resource "azurerm_subnet" "test_b" {
  name                 = "acctestsubnetb211029015322163822"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.4.0/24"
  service_endpoints    = ["Microsoft.CognitiveServices"]
}


resource "azurerm_cognitive_account" "test" {
  name                  = "acctestcogacc-211029015322163822"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  kind                  = "Face"
  sku_name              = "S0"
  custom_subdomain_name = "acctestcogacc-211029015322163822"

  network_acls {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.test_a.id, azurerm_subnet.test_b.id]
  }
}
