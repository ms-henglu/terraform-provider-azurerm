

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fw-230929064921485537"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet230929064921485537"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip230929064921485537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "test" {
  name                = "acctestfirewall230929064921485537"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.test.id
    public_ip_address_id = azurerm_public_ip.test.id
  }
  threat_intel_mode = "Deny"
}


resource "azurerm_firewall_application_rule_collection" "test" {
  name                = "acctestarc"
  azure_firewall_name = azurerm_firewall.test.name
  resource_group_name = azurerm_resource_group.test.name
  priority            = 100
  action              = "Allow"

  rule {
    name        = "rule1"
    description = "test description"
    fqdn_tags   = ["WindowsDiagnostics", "AzureBackup"]
    source_addresses = [
      "10.0.0.0/16",
    ]
  }
}
