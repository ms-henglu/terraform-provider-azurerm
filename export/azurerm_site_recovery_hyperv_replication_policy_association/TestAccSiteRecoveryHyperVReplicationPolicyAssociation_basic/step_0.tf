

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-231020041729062813"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-231020041729062813"
  ip_name              = "acctest-nested-ip-231020041729062813"
  vm_name              = "acctest-nested-vm-231020041729062813"
  nic_name             = "acctest-nested-nic-231020041729062813"
  disk_name            = "acctest-nested-disk-231020041729062813"
  keyvault_name        = "acctkv231020041729062813"
  nsg_name             = "acctest-nested-nsg-231020041729062813"
  recovery_vault_name  = "acctest-nested-recovery-vault-231020041729062813"
  recovery_site_name   = "acctest-nested-recovery-site-231020041729062813"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsazc6yz"
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
