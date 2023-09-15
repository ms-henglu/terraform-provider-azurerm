

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-hsm-230915023527154508"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230915023527154508"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test2" {
  name                 = "acctest-hsmsubnet-230915023527154508"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.2.1.0/24"]

  delegation {
    name = "first"

    service_delegation {
      name = "Microsoft.HardwareSecurityModules/dedicatedHSMs"

      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "test3" {
  name                 = "gatewaysubnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.2.255.0/26"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctest-pip-230915023527154508"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "test" {
  name                = "acctest-vnetgateway-230915023527154508"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  type     = "ExpressRoute"
  vpn_type = "PolicyBased"
  sku      = "Standard"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.test.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.test3.id
  }
}


resource "azurerm_dedicated_hardware_security_module" "test" {
  name                = "acctest-hsm-fdq6f"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "payShield10K_LMK1_CPS60"

  network_profile {
    network_interface_private_ip_addresses = ["10.2.1.8"]
    subnet_id                              = azurerm_subnet.test2.id
  }

  management_network_profile {
    network_interface_private_ip_addresses = ["10.2.1.9"]
    subnet_id                              = azurerm_subnet.test2.id
  }

  stamp_id = "stamp2"

  tags = {
    env = "Test"
  }

  depends_on = [azurerm_virtual_network_gateway.test]
}
