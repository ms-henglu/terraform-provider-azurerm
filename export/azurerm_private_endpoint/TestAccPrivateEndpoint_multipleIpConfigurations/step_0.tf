

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-privatelink-240105061256866488"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvnet-240105061256866488"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.5.0.0/16"]
}

resource "azurerm_subnet" "service" {
  name                 = "acctestsnetservice-240105061256866488"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.1.0/24"]

  enforce_private_link_service_network_policies = true
}

resource "azurerm_subnet" "endpoint" {
  name                 = "acctestsnetendpoint-240105061256866488"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.5.2.0/24"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240105061256866488"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-240105061256866488"
  sku                 = "Standard"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  frontend_ip_configuration {
    name                 = azurerm_public_ip.test.name
    public_ip_address_id = azurerm_public_ip.test.id
  }
}



resource "azurerm_private_link_service" "test" {
  name                           = "acctestPLS-240105061256866488"
  location                       = azurerm_resource_group.test.location
  resource_group_name            = azurerm_resource_group.test.name
  auto_approval_subscription_ids = [data.azurerm_subscription.current.subscription_id]
  visibility_subscription_ids    = [data.azurerm_subscription.current.subscription_id]

  nat_ip_configuration {
    name      = "primaryIpConfiguration-240105061256866488"
    primary   = true
    subnet_id = azurerm_subnet.service.id
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_lb.test.frontend_ip_configuration.0.id
  ]
}



locals {
  ip_configs = {
    "SiteRecovery-prot2" = "10.5.2.24"
    "SiteRecovery-srs1"  = "10.5.2.25"
    "SiteRecovery-id1"   = "10.5.2.26"
    "SiteRecovery-tel1"  = "10.5.2.27"
    "SiteRecovery-rcm1"  = "10.5.2.28"
  }
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-240105061256866488"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  soft_delete_enabled = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "test" {
  name                = "acctest-privatelink-240105061256866488"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "acctest-privatelink-240105061256866488"
    is_manual_connection           = false
    subresource_names              = ["AzureSiteRecovery"]
    private_connection_resource_id = azurerm_recovery_services_vault.test.id
  }

  dynamic "ip_configuration" {
    for_each = local.ip_configs

    content {
      name               = ip_configuration.key
      private_ip_address = ip_configuration.value
      subresource_name   = "AzureSiteRecovery"
      member_name        = ip_configuration.key
    }
  }
}
