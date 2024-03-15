



provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PANGFWVN-240315123752425635"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-240315123752425635"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "egress" {
  name                = "acctestpublicip-240315123752425635-e"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "test" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet240315123752425635"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "test1" {
  name                 = "acctest-pangfw-240315123752425635-1"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "trusted"

    service_delegation {
      name = "PaloAltoNetworks.Cloudngfw/firewalls"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "test1" {
  subnet_id                 = azurerm_subnet.test1.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_subnet" "test2" {
  name                 = "acctest-pangfw-240315123752425635-2"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "untrusted"

    service_delegation {
      name = "PaloAltoNetworks.Cloudngfw/firewalls"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "test2" {
  subnet_id                 = azurerm_subnet.test2.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240315123752425635"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack_rule" "test" {
  name         = "testacc-palr-240315123752425635"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  priority     = 1001
  action       = "Allow"

  applications = ["any"]

  destination {
    cidrs = ["any"]
  }

  source {
    cidrs = ["any"]
  }
}


resource "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack" "test" {
  name                = "acctest-ngfwvn-240315123752425635"
  resource_group_name = azurerm_resource_group.test.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.test.id

  network_profile {
    public_ip_address_ids = [azurerm_public_ip.test.id]

    vnet_configuration {
      virtual_network_id  = azurerm_virtual_network.test.id
      trusted_subnet_id   = azurerm_subnet.test1.id
      untrusted_subnet_id = azurerm_subnet.test2.id
    }
  }
}


resource "azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack" "import" {
  name                = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.name
  resource_group_name = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.resource_group_name
  rulestack_id        = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.rulestack_id

  network_profile {
    public_ip_address_ids = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.network_profile.0.public_ip_address_ids

    vnet_configuration {
      virtual_network_id  = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.network_profile.0.vnet_configuration.0.virtual_network_id
      trusted_subnet_id   = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.network_profile.0.vnet_configuration.0.trusted_subnet_id
      untrusted_subnet_id = azurerm_palo_alto_next_generation_firewall_virtual_network_local_rulestack.test.network_profile.0.vnet_configuration.0.untrusted_subnet_id
    }
  }
}
