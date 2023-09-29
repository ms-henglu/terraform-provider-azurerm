
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PANGFWVH-230929065452018753"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-230929065452018753"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "egress" {
  name                = "acctestpublicip-230929065452018753-e"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-230929065452018753"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestVHUB-230929065452018753"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"

  tags = {
    hubSaaSPreview = "true"
  }
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230929065452018753"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack_rule" "test" {
  name         = "testacc-palr-230929065452018753"
  rulestack_id = azurerm_palo_alto_local_rulestack.test.id
  priority     = 1001
  action       = "DenySilent"

  applications = ["any"]

  destination {
    cidrs = ["any"]
  }

  source {
    cidrs = ["any"]
  }
}

resource "azurerm_palo_alto_virtual_network_appliance" "test" {
  name           = "testAcc-panva-230929065452018753"
  virtual_hub_id = azurerm_virtual_hub.test.id
}




resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "test" {
  name                = "acctest-ngfwvh-230929065452018753"
  resource_group_name = azurerm_resource_group.test.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.test.id

  network_profile {
    virtual_hub_id               = azurerm_virtual_hub.test.id
    network_virtual_appliance_id = azurerm_palo_alto_virtual_network_appliance.test.id
    public_ip_address_ids        = [azurerm_public_ip.test.id]
  }

  dns_settings {
    use_azure_dns = true
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
