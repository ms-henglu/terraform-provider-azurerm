
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-240112224958156723"
  location = "West Europe"
}

resource "azurerm_ip_group" "test1" {
  name                = "acceptanceTestIpGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidrs = ["172.16.240.0/20"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}

resource "azurerm_ip_group" "test2" {
  name                = "acceptanceTestIpGroup2"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  cidrs = ["172.17.240.0/20"]

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}

resource "azurerm_firewall_policy" "test" {
  name                = "fwpol-test-policy"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_firewall_policy_rule_collection_group" "test" {
  name               = "fwpol-test"
  firewall_policy_id = azurerm_firewall_policy.test.id
  priority           = 100

  network_rule_collection {
    name     = "network-rule-collection1"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "network-rule-collection1-rule1"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.test1.id]
      destination_ip_groups = [azurerm_ip_group.test2.id]
      destination_ports     = ["443"]
    }
  }

  network_rule_collection {
    name     = "network-rule-collection2"
    priority = 200
    action   = "Allow"
    rule {
      name                  = "network-rule-collection1-rule1"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.test2.id]
      destination_ip_groups = [azurerm_ip_group.test1.id]
      destination_ports     = ["443"]
    }
  }
}


resource "azurerm_virtual_network" "test" {
  name                = "testvnet"
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
  name                = "pip-fw"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "test" {
  name                = "testfirewall"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  firewall_policy_id = azurerm_firewall_policy.test.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.test.id
    public_ip_address_id = azurerm_public_ip.test.id
  }
}
