
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PANGFWVN-240119025601478064"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-240119025601478064"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "egress" {
  name                = "acctestpublicip-240119025601478064-e"
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
  name                = "acctestvirtnet240119025601478064"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "test1" {
  name                 = "acctest-pangfw-240119025601478064-1"
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
  name                 = "acctest-pangfw-240119025601478064-2"
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
  name                = "testAcc-palrs-240119025601478064"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack_rule" "test" {
  name         = "testacc-palr-240119025601478064"
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
  name                = "acctest-ngfwvn-240119025601478064"
  resource_group_name = azurerm_resource_group.test.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.test.id

  network_profile {
    public_ip_address_ids     = [azurerm_public_ip.test.id]
    egress_nat_ip_address_ids = [azurerm_public_ip.egress.id]

    vnet_configuration {
      virtual_network_id  = azurerm_virtual_network.test.id
      trusted_subnet_id   = azurerm_subnet.test1.id
      untrusted_subnet_id = azurerm_subnet.test2.id
    }
  }

  dns_settings {
    dns_servers = ["8.8.8.8", "8.8.4.4"]
  }

  destination_nat {
    name     = "testDNAT-1"
    protocol = "TCP"
    frontend_config {
      public_ip_address_id = azurerm_public_ip.test.id
      port                 = 8081
    }
    backend_config {
      public_ip_address = "10.0.1.101"
      port              = 18081
    }
  }

  destination_nat {
    name     = "testDNAT-2"
    protocol = "UDP"
    frontend_config {
      public_ip_address_id = azurerm_public_ip.test.id
      port                 = 8082
    }
    backend_config {
      public_ip_address = "10.0.1.102"
      port              = 18082
    }
  }
}
