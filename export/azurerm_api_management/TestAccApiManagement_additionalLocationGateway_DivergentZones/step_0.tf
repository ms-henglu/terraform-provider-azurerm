
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033744198802"
  location = "West Europe"
  tags = {
    owner = "Dom Routley"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVNET-240112033744198802"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-gateway"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = azurerm_virtual_network.test.address_space
}

resource "azurerm_network_security_group" "test" {
  name                = "acctest-NSG-240112033744198802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "Client_communication_to_API_Management"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Secure_Client_communication_to_API_Management"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Management_endpoint_for_Azure_portal_and_Powershell"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Authenticate_To_Azure_Active_Directory"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.test.id
  network_security_group_id = azurerm_network_security_group.test.id
}

resource "azurerm_public_ip" "test" {
  name                = "acctestIP-240112033744198802"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "acctest-ip-240112033744198802"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG2-240112033744198802"
  location = "West US 2"
  tags = {
    owner = "Dom Routley"
  }
}

resource "azurerm_virtual_network" "test2" {
  name                = "acctestVNET2-240112033744198802"
  resource_group_name = azurerm_resource_group.test2.name
  location            = azurerm_resource_group.test2.location
  address_space       = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "test2" {
  name                 = "acctest2-gateway"
  resource_group_name  = azurerm_resource_group.test2.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = azurerm_virtual_network.test2.address_space
}

resource "azurerm_network_security_group" "test2" {
  name                = "acctest-NSG2-240112033744198802"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name

  security_rule {
    name                       = "Client_communication_to_API_Management"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Secure_Client_communication_to_API_Management"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Management_endpoint_for_Azure_portal_and_Powershell"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "Authenticate_To_Azure_Active_Directory"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "test2" {
  subnet_id                 = azurerm_subnet.test2.id
  network_security_group_id = azurerm_network_security_group.test2.id
}

resource "azurerm_public_ip" "test2" {
  name                = "acctest2IP-240112033744198802"
  resource_group_name = azurerm_resource_group.test2.name
  location            = azurerm_resource_group.test2.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "acctest2-ip-240112033744198802"
}

resource "azurerm_api_management" "test" {
  name                 = "acctestAM-240112033744198802"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  publisher_name       = "pub1"
  publisher_email      = "pub1@email.com"
  sku_name             = "Premium_2"
  public_ip_address_id = azurerm_public_ip.test.id
  virtual_network_type = "Internal"
  zones                = ["1", "2"]

  virtual_network_configuration {
    subnet_id = azurerm_subnet.test.id
  }

  additional_location {
    location             = azurerm_resource_group.test2.location
    public_ip_address_id = azurerm_public_ip.test2.id
    virtual_network_configuration {
      subnet_id = azurerm_subnet.test2.id
    }
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.test,
    azurerm_subnet_network_security_group_association.test2,
  ]
}
