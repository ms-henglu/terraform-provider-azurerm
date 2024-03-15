



provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PANGFWVH-240315123752424394"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-240315123752424394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "egress" {
  name                = "acctestpublicip-240315123752424394-e"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan-240315123752424394"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctestVHUB-240315123752424394"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"

  tags = {
    hubSaaSPreview = "true"
  }
}

resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240315123752424394"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

resource "azurerm_palo_alto_local_rulestack_rule" "test" {
  name         = "testacc-palr-240315123752424394"
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
  name           = "testAcc-panva-240315123752424394"
  virtual_hub_id = azurerm_virtual_hub.test.id
}




resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "test" {
  name                = "acctest-ngfwvh-240315123752424394"
  resource_group_name = azurerm_resource_group.test.name
  rulestack_id        = azurerm_palo_alto_local_rulestack.test.id

  network_profile {
    virtual_hub_id               = azurerm_virtual_hub.test.id
    network_virtual_appliance_id = azurerm_palo_alto_virtual_network_appliance.test.id
    public_ip_address_ids        = [azurerm_public_ip.test.id]
  }
}


resource "azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack" "import" {
  name                = azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.test.name
  resource_group_name = azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.test.resource_group_name
  rulestack_id        = azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.test.rulestack_id

  network_profile {
    virtual_hub_id               = azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.test.network_profile.0.virtual_hub_id
    network_virtual_appliance_id = azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.test.network_profile.0.network_virtual_appliance_id
    public_ip_address_ids        = azurerm_palo_alto_next_generation_firewall_virtual_hub_local_rulestack.test.network_profile.0.public_ip_address_ids
  }
}
