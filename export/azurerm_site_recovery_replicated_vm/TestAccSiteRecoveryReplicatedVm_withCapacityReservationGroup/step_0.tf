

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-recovery-230227033301622093-1"
  location = "West Europe"
}

resource "azurerm_resource_group" "test2" {
  name     = "acctestRG-recovery-230227033301622093-2"
  location = "West US 2"
}

resource "azurerm_recovery_services_vault" "test" {
  name                = "acctest-vault-230227033301622093"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_fabric" "test1" {
  resource_group_name = azurerm_resource_group.test2.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  name                = "acctest-fabric1-230227033301622093"
  location            = azurerm_resource_group.test.location
}

resource "azurerm_site_recovery_fabric" "test2" {
  resource_group_name = azurerm_resource_group.test2.name
  recovery_vault_name = azurerm_recovery_services_vault.test.name
  name                = "acctest-fabric2-230227033301622093"
  location            = azurerm_resource_group.test2.location
  depends_on          = [azurerm_site_recovery_fabric.test1]
}

resource "azurerm_site_recovery_protection_container" "test1" {
  resource_group_name  = azurerm_resource_group.test2.name
  recovery_vault_name  = azurerm_recovery_services_vault.test.name
  recovery_fabric_name = azurerm_site_recovery_fabric.test1.name
  name                 = "acctest-protection-cont1-230227033301622093"
}

resource "azurerm_site_recovery_protection_container" "test2" {
  resource_group_name  = azurerm_resource_group.test2.name
  recovery_vault_name  = azurerm_recovery_services_vault.test.name
  recovery_fabric_name = azurerm_site_recovery_fabric.test2.name
  name                 = "acctest-protection-cont2-230227033301622093"
}

resource "azurerm_site_recovery_replication_policy" "test" {
  resource_group_name                                  = azurerm_resource_group.test2.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.test.name
  name                                                 = "acctest-policy-230227033301622093"
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}

resource "azurerm_site_recovery_protection_container_mapping" "test" {
  resource_group_name                       = azurerm_resource_group.test2.name
  recovery_vault_name                       = azurerm_recovery_services_vault.test.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.test1.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.test1.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.test2.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.test.id
  name                                      = "mapping-230227033301622093"
}

resource "azurerm_virtual_network" "test1" {
  name                = "net-230227033301622093"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.1.0/24"]
  location            = azurerm_site_recovery_fabric.test1.location
}

resource "azurerm_subnet" "test1" {
  name                 = "snet-230227033301622093"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test1.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_virtual_network" "test2" {
  name                = "net2-230227033301622093"
  resource_group_name = azurerm_resource_group.test2.name
  address_space       = ["192.168.2.0/24"]
  location            = azurerm_site_recovery_fabric.test2.location
}

resource "azurerm_subnet" "test2" {
  name                 = "snet-230227033301622093_2"
  resource_group_name  = azurerm_resource_group.test2.name
  virtual_network_name = azurerm_virtual_network.test2.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_site_recovery_network_mapping" "test" {
  resource_group_name         = azurerm_resource_group.test2.name
  recovery_vault_name         = azurerm_recovery_services_vault.test.name
  name                        = "mapping-230227033301622093"
  source_recovery_fabric_name = azurerm_site_recovery_fabric.test1.name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.test2.name
  source_network_id           = azurerm_virtual_network.test1.id
  target_network_id           = azurerm_virtual_network.test2.id
}

resource "azurerm_network_interface" "test" {
  name                = "vm-230227033301622093"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "vm-230227033301622093"
    subnet_id                     = azurerm_subnet.test1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test-source.id
  }
}

resource "azurerm_virtual_machine" "test" {
  name                = "vm-230227033301622093"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  vm_size = "Standard_B1s"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "disk-230227033301622093"
    os_type           = "Linux"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    admin_username = "testadmin"
    admin_password = "Password1234!"
    computer_name  = "vm-230227033301622093"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  network_interface_ids = [azurerm_network_interface.test.id]

 
}

resource "azurerm_public_ip" "test-source" {
  name                = "pubip230227033301622093-source"
  allocation_method   = "Static"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
}

resource "azurerm_public_ip" "test-recovery" {
  name                = "pubip230227033301622093-recovery"
  allocation_method   = "Static"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
  sku                 = "Basic"
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa230227033301622093"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}


resource "azurerm_capacity_reservation_group" "test" {
  name                = "acctest-crg-230227033301622093"
  location            = azurerm_resource_group.test2.location
  resource_group_name = azurerm_resource_group.test2.name
}

resource "azurerm_capacity_reservation" "test" {
  name                          = "acctest-ccr-230227033301622093"
  capacity_reservation_group_id = azurerm_capacity_reservation_group.test.id

  sku {
    name     = "Standard_B1s"
    capacity = 1
  }
}

resource "azurerm_site_recovery_replicated_vm" "test" {
  name                                      = "repl-230227033301622093"
  resource_group_name                       = azurerm_resource_group.test2.name
  recovery_vault_name                       = azurerm_recovery_services_vault.test.name
  source_vm_id                              = azurerm_virtual_machine.test.id
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.test1.name
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.test.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.test1.name

  target_resource_group_id                = azurerm_resource_group.test2.id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.test2.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.test2.id
  target_capacity_reservation_group_id    = azurerm_capacity_reservation_group.test.id

  managed_disk {
    disk_id                    = azurerm_virtual_machine.test.storage_os_disk[0].managed_disk_id
    staging_storage_account_id = azurerm_storage_account.test.id
    target_resource_group_id   = azurerm_resource_group.test2.id
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }

  network_interface {
    source_network_interface_id   = azurerm_network_interface.test.id
    target_subnet_name            = azurerm_subnet.test2.name
    recovery_public_ip_address_id = azurerm_public_ip.test-recovery.id
  }

  depends_on = [
    azurerm_site_recovery_protection_container_mapping.test,
    azurerm_site_recovery_network_mapping.test,
    azurerm_capacity_reservation.test,
  ]
}

