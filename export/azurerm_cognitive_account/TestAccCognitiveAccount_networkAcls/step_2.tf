

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-cognitive-230414020856386150"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230414020856386150"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test_a" {
  name                 = "acctestsubneta230414020856386150"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.CognitiveServices"]
}

resource "azurerm_subnet" "test_b" {
  name                 = "acctestsubnetb230414020856386150"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.4.0/24"]
  service_endpoints    = ["Microsoft.CognitiveServices"]
}

resource "azurerm_cognitive_account" "test" {
  name                  = "acctestcogacc-230414020856386150"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  kind                  = "Face"
  sku_name              = "S0"
  custom_subdomain_name = "acctestcogacc-230414020856386150"

  network_acls {
    default_action = "Allow"
    ip_rules       = ["123.0.0.101"]
    virtual_network_rules {
      subnet_id = azurerm_subnet.test_a.id
    }
    virtual_network_rules {
      subnet_id = azurerm_subnet.test_b.id
    }
  }
}
