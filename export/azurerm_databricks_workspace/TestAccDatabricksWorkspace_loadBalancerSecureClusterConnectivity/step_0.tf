
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-221117230738634802"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-221117230738634802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public" {
  name                 = "acctest-sn-public-221117230738634802"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "acctest"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private" {
  name                 = "acctest-sn-private-221117230738634802"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "acctest"

    service_delegation {
      name = "Microsoft.Databricks/workspaces"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "acctest-nsg-221117230738634802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_databricks_workspace" "test" {
  name                        = "acctestDBW-221117230738634802"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku                         = "premium"
  managed_resource_group_name = "acctestRG-DBW-221117230738634802-managed"

  public_network_access_enabled         = true
  load_balancer_backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  custom_parameters {
    no_public_ip        = true
    public_subnet_name  = azurerm_subnet.public.name
    private_subnet_name = azurerm_subnet.private.name
    virtual_network_id  = azurerm_virtual_network.test.id

    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }

  tags = {
    Environment = "Production"
    Pricing     = "Premium"
  }
}

resource "azurerm_public_ip" "test" {
  name                    = "acctestpublicip-221117230738634802"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  idle_timeout_in_minutes = 4
  allocation_method       = "Static"

  sku = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-221117230738634802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "acctest-PIP-221117230738634802"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_outbound_rule" "test" {
  name                     = "OutboundRule-221117230738634802"
  loadbalancer_id          = azurerm_lb.test.id
  protocol                 = "All"
  enable_tcp_reset         = true
  allocated_outbound_ports = 1024
  idle_timeout_in_minutes  = 4

  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id

  frontend_ip_configuration {
    name = azurerm_lb.test.frontend_ip_configuration.0.name
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "be-221117230738634802"
}
