

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240315122207578573"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVNET-240315122207578573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestSNET-240315122207578573"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "test" {
  name                = "acctest-NSG-240315122207578573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_network_security_rule" "client" {
  name                        = "Client_communication_to_API_Management"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_network_security_rule" "secure_client" {
  name                        = "Secure_Client_communication_to_API_Management"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_network_security_rule" "endpoint" {
  name                        = "Management_endpoint_for_Azure_portal_and_Powershell"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}

resource "azurerm_network_security_rule" "authenticate" {
  name                        = "Authenticate_To_Azure_Active_Directory"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test.name
  network_security_group_name = azurerm_network_security_group.test.name
}


resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-240315122207578573-2"
  location = "West US 2"
}

// subnet2 from the second location
resource "azurerm_virtual_network" "test2" {
  name                = "acctestVNET2-240315122207578573"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "test2" {
  name                 = "acctestSNET2-240315122207578573"
  resource_group_name  = azurerm_resource_group.test2.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "test2" {
  name                = "acctest-NSG2-240315122207578573"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
}

resource "azurerm_subnet_network_security_group_association" "test2" {
  subnet_id                 = azurerm_subnet.test2.id
  network_security_group_id = azurerm_network_security_group.test2.id
}

resource "azurerm_network_security_rule" "client2" {
  name                        = "Client_communication_to_API_Management"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test2.name
  network_security_group_name = azurerm_network_security_group.test2.name
}

resource "azurerm_network_security_rule" "secure_client2" {
  name                        = "Secure_Client_communication_to_API_Management"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test2.name
  network_security_group_name = azurerm_network_security_group.test2.name
}

resource "azurerm_network_security_rule" "endpoint2" {
  name                        = "Management_endpoint_for_Azure_portal_and_Powershell"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3443"
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test2.name
  network_security_group_name = azurerm_network_security_group.test2.name
}

resource "azurerm_network_security_rule" "authenticate2" {
  name                        = "Authenticate_To_Azure_Active_Directory"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = "ApiManagement"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.test2.name
  network_security_group_name = azurerm_network_security_group.test2.name
}

resource "azurerm_public_ip" "test1" {
  name                = "acctest-IP1-zlllh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "acctest-ip1-zlllh"
}

resource "azurerm_public_ip" "test2" {
  name                = "acctest-IP2-zlllh"
  resource_group_name = azurerm_resource_group.test2.name
  location            = azurerm_resource_group.test2.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "acctest-ip2-zlllh"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240315122207578573"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Premium_1"

  additional_location {
    location = azurerm_resource_group.test2.location
    capacity = 1

    public_ip_address_id = azurerm_public_ip.test2.id
    virtual_network_configuration {
      subnet_id = azurerm_subnet.test2.id
    }
  }

  virtual_network_type = "Internal"
  public_ip_address_id = azurerm_public_ip.test1.id
  virtual_network_configuration {
    subnet_id = azurerm_subnet.test.id
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.test,
    azurerm_subnet_network_security_group_association.test2,
  ]
}
