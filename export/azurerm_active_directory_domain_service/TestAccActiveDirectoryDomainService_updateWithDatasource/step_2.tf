

provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acclongtestRG-aadds-230728032239257963"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestVnet-aadds-230728032239257963"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aadds" {
  name                 = "acctestSubnet-aadds-230728032239257963"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.test.address_space.0, 8, 0)]
}

resource "azurerm_subnet" "workload" {
  name                 = "acctestSubnet-workload-230728032239257963"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.test.address_space.0, 8, 1)]
}

resource "azurerm_network_security_group" "aadds" {
  name                = "acctestNSG-aadds-230728032239257963"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  security_rule {
    name                       = "AllowSyncWithAzureAD"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLDAPS"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource azurerm_subnet_network_security_group_association "test" {
  subnet_id                 = azurerm_subnet.aadds.id
  network_security_group_id = azurerm_network_security_group.aadds.id
}

data "azuread_domains" "test" {
  only_initial = true
}

resource "azuread_service_principal" "test" {
  application_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36" // published app for domain services
  use_existing   = true
}

resource "azuread_group" "test" {
  display_name     = "AAD DC Administrators"
  description      = "Delegated group to administer Azure AD Domain Services"
  security_enabled = true
}

resource "azuread_user" "test" {
  user_principal_name = "acctestAADDSAdminUser-230728032239257963@${data.azuread_domains.test.domains.0.domain_name}"
  display_name        = "acctestAADDSAdminUser-230728032239257963"
  password            = "p@$$Wdbcptld"
}

resource "azuread_group_member" "test" {
  group_object_id  = azuread_group.test.object_id
  member_object_id = azuread_user.test.object_id
}

resource "azurerm_active_directory_domain_service" "test" {
  name                = "acctest-w0emy"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  domain_name               = "never.gonna.shut.you.down"
  sku                       = "Enterprise"
  domain_configuration_type = "FullySynced"
  filtered_sync_enabled     = false

  initial_replica_set {
    subnet_id = azurerm_subnet.aadds.id
  }

  notifications {
    additional_recipients = ["notifyA@example.net", "notifyB@example.org"]
    notify_dc_admins      = true
    notify_global_admins  = true
  }

  secure_ldap {
    enabled                  = true
    external_access_enabled  = true
    pfx_certificate          = "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"
    pfx_certificate_password = "qwer5678"
  }

  security {
    kerberos_armoring_enabled       = true
    kerberos_rc4_encryption_enabled = true
    ntlm_v1_enabled                 = true
    sync_kerberos_passwords         = true
    sync_ntlm_passwords             = true
    sync_on_prem_passwords          = true
    tls_v1_enabled                  = true
  }

  tags = {
    Environment = "test"
  }

  depends_on = [
    azuread_group.test,
    azuread_group_member.test,
    azuread_service_principal.test,
    azuread_user.test,
    azurerm_subnet_network_security_group_association.test,
  ]
}

resource "azurerm_virtual_network_dns_servers" "test" {
  virtual_network_id = azurerm_virtual_network.test.id
  dns_servers        = azurerm_active_directory_domain_service.test.initial_replica_set.0.domain_controller_ip_addresses
}


resource "azurerm_resource_group" "test_secondary" {
  name     = "acclongtestRG-aadds-secondary-230728032239257963"
  location = "West US 2"
}

resource "azurerm_virtual_network" "test_secondary" {
  name                = "acctestVnet-aadds-secondary-230728032239257963"
  location            = azurerm_resource_group.test_secondary.location
  resource_group_name = azurerm_resource_group.test_secondary.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "aadds_secondary" {
  name                 = "acctestSubnet-aadds-secondary-230728032239257963"
  resource_group_name  = azurerm_resource_group.test_secondary.name
  virtual_network_name = azurerm_virtual_network.test_secondary.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.test_secondary.address_space.0, 8, 0)]
}

resource "azurerm_subnet" "workload_secondary" {
  name                 = "acctestSubnet-workload-secondary-230728032239257963"
  resource_group_name  = azurerm_resource_group.test_secondary.name
  virtual_network_name = azurerm_virtual_network.test_secondary.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.test_secondary.address_space.0, 8, 1)]
}

resource "azurerm_network_security_group" "aadds_secondary" {
  name                = "acctestNSG-aadds-secondary-230728032239257963"
  location            = azurerm_resource_group.test_secondary.location
  resource_group_name = azurerm_resource_group.test_secondary.name

  security_rule {
    name                       = "AllowSyncWithAzureAD"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLDAPS"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource azurerm_subnet_network_security_group_association "test_secondary" {
  subnet_id                 = azurerm_subnet.aadds_secondary.id
  network_security_group_id = azurerm_network_security_group.aadds_secondary.id
}

resource "azurerm_virtual_network_peering" "test_primary_secondary" {
  name                      = "acctestVnet-aadds-primary-secondary-230728032239257963"
  resource_group_name       = azurerm_virtual_network.test.resource_group_name
  virtual_network_name      = azurerm_virtual_network.test.name
  remote_virtual_network_id = azurerm_virtual_network.test_secondary.id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  allow_virtual_network_access = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_subent.aadds_secondary,
    azurerm_subent.workload_secondary,
  ]
}

resource "azurerm_virtual_network_peering" "test_secondary_primary" {
  name                      = "acctestVnet-aadds-secondary-primary-230728032239257963"
  resource_group_name       = azurerm_virtual_network.test_secondary.resource_group_name
  virtual_network_name      = azurerm_virtual_network.test_secondary.name
  remote_virtual_network_id = azurerm_virtual_network.test.id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  allow_virtual_network_access = true
  use_remote_gateways          = false

  depends_on = [
    azurerm_subent.aadds_secondary,
    azurerm_subent.workload_secondary,
  ]
}

resource "azurerm_active_directory_domain_service_replica_set" "test_secondary" {
  domain_service_id = azurerm_active_directory_domain_service.test.id
  location          = azurerm_resource_group.test_secondary.location
  subnet_id         = azurerm_subnet.aadds_secondary.id

  depends_on = [
    azurerm_subnet_network_security_group_association.test_secondary,
    azurerm_virtual_network_peering.test_primary_secondary,
    azurerm_virtual_network_peering.test_secondary_primary,
  ]
}

resource "azurerm_virtual_network_dns_servers" "test_secondary" {
  virtual_network_id = azurerm_virtual_network.test_secondary.id
  dns_servers        = azurerm_active_directory_domain_service_replica_set.test_secondary.domain_controller_ip_addresses
}
