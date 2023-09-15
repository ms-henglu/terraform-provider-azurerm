




provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-230915024052096471"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-230915024052096471"
  ip_name              = "acctest-nested-ip-230915024052096471"
  vm_name              = "acctest-nested-vm-230915024052096471"
  nic_name             = "acctest-nested-nic-230915024052096471"
  disk_name            = "acctest-nested-disk-230915024052096471"
  keyvault_name        = "acctkv230915024052096471"
  nsg_name             = "acctest-nested-nsg-230915024052096471"
  recovery_vault_name  = "acctest-nested-recovery-vault-230915024052096471"
  recovery_site_name   = "acctest-nested-recovery-site-230915024052096471"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsaqsm0y"
}

resource "azurerm_resource_group" "hybrid" {
  name     = local.rg_name
  location = local.location
}


resource "azurerm_recovery_services_vault" "test" {
  name                = local.recovery_vault_name
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name
  sku                 = "Standard"

  soft_delete_enabled = false
}

resource "azurerm_site_recovery_services_vault_hyperv_site" "test" {
  name              = local.recovery_site_name
  recovery_vault_id = azurerm_recovery_services_vault.test.id
}


variable "hyperv_host_registration_key" {
  type = string
}

resource "azurerm_virtual_network" "hybrid" {
  name                = local.vn_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name
}

resource "azurerm_subnet" "hybrid" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.hybrid.name
  virtual_network_name = azurerm_virtual_network.hybrid.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_public_ip" "host" {
  name                = local.ip_name
  resource_group_name = azurerm_resource_group.hybrid.name
  location            = azurerm_resource_group.hybrid.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "host" {
  name                = local.nic_name
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name

  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hybrid.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.host.id
  }
}

resource "azurerm_windows_virtual_machine" "host" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.hybrid.name
  location            = azurerm_resource_group.hybrid.location
  size                = "Standard_D8as_v5"
  admin_username      = local.admin_name
  admin_password      = "AZ$%097IE!"
  computer_name       = "nested-Host"

  network_interface_ids = [
    azurerm_network_interface.host.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>AZ$%097IE!</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${local.admin_name}</Username></AutoLogon>"
  }

  winrm_listener {
    protocol        = "Https"
    certificate_url = azurerm_key_vault_certificate.winrm.secret_id
  }

  secret {
    key_vault_id = azurerm_key_vault.hybird.id

    certificate {
      store = "My"
      url   = azurerm_key_vault_certificate.winrm.secret_id
    }
  }

  connection {
    host     = self.public_ip_address
    type     = "winrm"
    user     = self.admin_username
    password = self.admin_password
    port     = 5986
    https    = true
    use_ntlm = true
    insecure = true
    timeout  = "60m"
  }

  provisioner "file" {
    content     = "${var.hyperv_host_registration_key}"
    destination = "c:/temp/hyperv-credential"
  }

  provisioner "remote-exec" { # setup HyperV could only be done by provisioner because CustomScriptExtension does not allow reboot the server.
    inline = [
      "powershell -command \"Set-NetConnectionProfile -InterfaceAlias Ethernet -NetworkCategory Private\"",
      "mkdir c:\\Disks",
      "mkdir C:\\Machines",
      "curl -o C:\\Disks\\VM1.vhd \"https://software-static.download.prss.microsoft.com/pr/download/17763.737.amd64fre.rs5_release_svc_refresh.190906-2324_server_serverdatacentereval_en-us_1.vhd\" -L",
      "curl -o C:\\AzureSiteRecoveryProvider.exe \"https://aka.ms/downloaddra_eus\" -L",
      "C:\\AzureSiteRecoveryProvider.exe /x:C:\\AzureSiteRecoveryProvider /q",
      "powershell -command \"Install-WindowsFeature -Name Hyper-V,Hyper-V-Powershell,Hyper-V-Tools -IncludeManagementTools\"",
    ]
  }

  lifecycle {
    ignore_changes = [tags, identity]
  }

}



data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "hybird" {
  name                = local.keyvault_name
  resource_group_name = azurerm_resource_group.hybrid.name
  location            = azurerm_resource_group.hybrid.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey",
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set",
    ]

    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "SetIssuers",
      "Update",
    ]
  }

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
}

resource "azurerm_key_vault_certificate" "winrm" {
  name         = local.cert_name
  key_vault_id = azurerm_key_vault.hybird.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${local.vm_name}"
      validity_in_months = 12
    }
  }
}




resource "azurerm_network_security_group" "hybrid" {
  name                = local.nsg_name
  location            = azurerm_resource_group.hybrid.location
  resource_group_name = azurerm_resource_group.hybrid.name

  security_rule {
    name                       = "allow-winrm"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  lifecycle {
    ignore_changes = [security_rule]
  }
}

resource "azurerm_network_interface_security_group_association" "hybrid" {
  network_interface_id      = azurerm_network_interface.host.id
  network_security_group_id = azurerm_network_security_group.hybrid.id
}


# register the server could only be done by CustomScriptExtension because it requires local admin to run.

resource "azurerm_storage_account" "hybrid" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.hybrid.name
  location                 = azurerm_resource_group.hybrid.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "hybrid" {
  name                  = "hyperv-setup"
  storage_account_name  = azurerm_storage_account.hybrid.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "hybrid" {
  scope                = azurerm_storage_account.hybrid.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_windows_virtual_machine.host.identity.0.principal_id
}

resource "azurerm_storage_blob" "setup_script" {
  name                   = "setup_script.ps1"
  storage_account_name   = azurerm_storage_account.hybrid.name
  storage_container_name = azurerm_storage_container.hybrid.name
  type                   = "Block"
  source_content         = <<EOF
Set-VMHost -VirtualHardDiskPath c:\Disks -VirtualMachinePath c:\Machines
New-VMSwitch -Name HyperV-NAT -SwitchType Internal
$switchIndex=(Get-NetAdapter -Name "vEthernet (HyperV-NAT)").ifIndex
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex $switchIndex
New-NetNat -Name HyperV-NAT -InternalIPInterfaceAddressPrefix 192.168.0.0/24
Install-WindowsFeature -Name DHCP -IncludeManagementTools
Add-DhcpServerv4Scope -Name "Hyper-V NAT" -StartRange 192.168.0.100 -EndRange 192.168.0.199 -SubnetMask 255.255.255.0 -LeaseDuration 0.00:59:00
Set-DhcpServerv4OptionValue -ScopeId 192.168.0.0 -DnsServer 168.63.129.16 -Router 192.168.0.1
New-NetFirewallRule -DisplayName "Allow all guest traffic" -Direction Inbound -RemoteAddress 192.168.0.0/24 -Profile Any -Action Allow
New-VM -Name VM1 -Generation 1 -MemoryStartupBytes 16GB -BootDevice VHD -VHDPath C:\Disks\VM1.vhd -SwitchName HyperV-NAT
Start-VM -Name VM1
C:\AzureSiteRecoveryProvider\SETUPDR.EXE /i
cd "C:\Program Files\Microsoft Azure Site Recovery Provider\"
.\DRConfigurator.exe /r /Friendlyname "acctest-nested-server" /Credentials "C:\temp\hyperv-credential"
EOF
}

resource "azurerm_virtual_machine_extension" "script" {
  name                       = "setup-provider"
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.host.id

  protected_settings = jsonencode(
    {
      "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File ${azurerm_storage_blob.setup_script.name}",
      "fileUris" = [
        azurerm_storage_blob.setup_script.url,
      ],
      "managedIdentity" = {}
    }
  )

  depends_on = [
    azurerm_role_assignment.hybrid
  ]
}



resource "azurerm_site_recovery_hyperv_replication_policy" "test" {
  recovery_vault_id                                  = azurerm_recovery_services_vault.test.id
  name                                               = "acctest-policy-230915024052096471"
  recovery_point_retention_in_hours                  = 2
  application_consistent_snapshot_frequency_in_hours = 1
  replication_interval_in_seconds                    = 300
}

resource "azurerm_site_recovery_hyperv_replication_policy_association" "test" {
  name           = "test-association"
  hyperv_site_id = azurerm_site_recovery_services_vault_hyperv_site.test.id
  policy_id      = azurerm_site_recovery_hyperv_replication_policy.test.id
}
