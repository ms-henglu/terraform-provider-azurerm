

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-230721015851689548"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-230721015851689548"
  ip_name              = "acctest-nested-ip-230721015851689548"
  vm_name              = "acctest-nested-vm-230721015851689548"
  nic_name             = "acctest-nested-nic-230721015851689548"
  disk_name            = "acctest-nested-disk-230721015851689548"
  keyvault_name        = "acctkv230721015851689548"
  nsg_name             = "acctest-nested-nsg-230721015851689548"
  recovery_vault_name  = "acctest-nested-recovery-vault-230721015851689548"
  recovery_site_name   = "acctest-nested-recovery-site-230721015851689548"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsa3449k"
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
