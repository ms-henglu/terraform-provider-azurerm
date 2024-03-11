


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-240311032938286919"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-240311032938286919"
  ip_name              = "acctest-nested-ip-240311032938286919"
  vm_name              = "acctest-nested-vm-240311032938286919"
  nic_name             = "acctest-nested-nic-240311032938286919"
  disk_name            = "acctest-nested-disk-240311032938286919"
  keyvault_name        = "acctkv240311032938286919"
  nsg_name             = "acctest-nested-nsg-240311032938286919"
  recovery_vault_name  = "acctest-nested-recovery-vault-240311032938286919"
  recovery_site_name   = "acctest-nested-recovery-site-240311032938286919"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsa6grqx"
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
  admin_password      = "emO(%2@L4)"
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
    content = "<AutoLogon><Password><Value>emO(%2@L4)</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${local.admin_name}</Username></AutoLogon>"
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

