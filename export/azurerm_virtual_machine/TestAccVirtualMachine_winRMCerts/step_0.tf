
variable "prefix" {
  default = "acctestzmkzv"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "${var.prefix}-resources"
  location = "West Europe"

  tags = {
    source = "TestAccVirtualMachine_winRMCerts"
  }
}

resource "azurerm_virtual_network" "test" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "${var.prefix}-nic"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_key_vault" "test" {
  name                = "${var.prefix}-keyvault"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"

  sku_name = "standard"

  tenant_id = "${data.azurerm_client_config.current.tenant_id}"

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.object_id}"

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

resource "azurerm_key_vault_certificate" "test" {
  name         = "${var.prefix}-cert"
  key_vault_id = azurerm_key_vault.test.id

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
      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=${azurerm_network_interface.test.private_ip_address}"
      validity_in_months = 12
    }
  }
}

resource "azurerm_virtual_machine" "test" {
  name                          = "${var.prefix}-vm"
  location                      = "${azurerm_resource_group.test.location}"
  resource_group_name           = "${azurerm_resource_group.test.name}"
  network_interface_ids         = ["${azurerm_network_interface.test.id}"]
  vm_size                       = "Standard_F2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm"
    admin_username = "mradministrator"
    admin_password = "Th15IsD0g1234!"
  }

  os_profile_windows_config {
    provision_vm_agent = true

    winrm {
      protocol        = "HTTPS"
      certificate_url = "${azurerm_key_vault_certificate.test.secret_id}"
    }
  }

  os_profile_secrets {
    source_vault_id = "${azurerm_key_vault.test.id}"

    vault_certificates {
      certificate_url   = "${azurerm_key_vault_certificate.test.secret_id}"
      certificate_store = "My"
    }
  }
}
