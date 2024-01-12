
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240112035015559656"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-rg-240112035015559656"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "outbounddns"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.64/28"]

  delegation {
    name = "Microsoft.Network.dnsResolvers"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      name    = "Microsoft.Network/dnsResolvers"
    }
  }
}

resource "azurerm_private_dns_resolver" "test" {
  name                = "acctest-dr-240112035015559656"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_network_id  = azurerm_virtual_network.test.id
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "test" {
  name                    = "acctest-droe-240112035015559656"
  private_dns_resolver_id = azurerm_private_dns_resolver.test.id
  location                = azurerm_private_dns_resolver.test.location
  subnet_id               = azurerm_subnet.test.id
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "test" {
  name                                       = "acctest-drdfr-240112035015559656"
  resource_group_name                        = azurerm_resource_group.test.name
  location                                   = azurerm_resource_group.test.location
  private_dns_resolver_outbound_endpoint_ids = [azurerm_private_dns_resolver_outbound_endpoint.test.id]
}


resource "azurerm_private_dns_resolver_forwarding_rule" "test" {
  name                      = "acctest-drfr-240112035015559656"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.test.id
  domain_name               = "onprem.local."
  enabled                   = true
  target_dns_servers {
    ip_address = "10.10.0.1"
    port       = 53
  }
  metadata = {
    key = "value"
  }
}
