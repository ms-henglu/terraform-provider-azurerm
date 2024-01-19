
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025039074518"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctvn1-240119025039074518"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctsub1-240119025039074518"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.EventHub"]
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctvn2-240119025039074518"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test2" {
  name                 = "acctsub2-240119025039074518"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = ["10.1.1.0/24"]
  service_endpoints    = ["Microsoft.EventHub"]
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "acctesteventhubnamespace-240119025039074518"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"
  capacity            = "2"

  network_rulesets {
    default_action = "Deny"

    virtual_network_rule {
      subnet_id = azurerm_subnet.test.id
    }

    virtual_network_rule {
      subnet_id = azurerm_subnet.test2.id
    }

    ip_rule {
      ip_mask = "10.0.1.0/24"
    }

    ip_rule {
      ip_mask = "10.1.1.0/24"
    }
  }
}
