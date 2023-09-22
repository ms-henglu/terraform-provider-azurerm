

locals {
  vm_name = "acctvm23"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922060812915901"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230922060812915901"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}


provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults       = false
      purge_soft_delete_on_destroy          = false
      purge_soft_deleted_keys_on_destroy    = false
      purge_soft_deleted_secrets_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "test" {
  count = 2

  name                   = "acctestkv${count.index}uyiqu"
  location               = azurerm_resource_group.test.location
  resource_group_name    = azurerm_resource_group.test.name
  tenant_id              = data.azurerm_client_config.current.tenant_id
  sku_name               = "standard"
  enabled_for_deployment = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Delete",
      "Get",
      "Set",
    ]
  }
}

resource "azurerm_key_vault_secret" "test" {
  count = 2

  name         = "secret"
  value        = "{\"commandToExecute\":\"echo $HOSTNAME\"}"
  key_vault_id = azurerm_key_vault.test[count.index].id
}

resource "azurerm_windows_virtual_machine_scale_set" "test" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  extension {
    name                 = "CustomScript"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.10"

    protected_settings_from_key_vault {
      secret_url      = azurerm_key_vault_secret.test[0].id
      source_vault_id = azurerm_key_vault.test[0].id
    }
  }
}
