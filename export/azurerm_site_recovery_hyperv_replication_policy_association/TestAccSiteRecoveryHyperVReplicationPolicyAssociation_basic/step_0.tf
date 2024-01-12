

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-240112225130076500"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-240112225130076500"
  ip_name              = "acctest-nested-ip-240112225130076500"
  vm_name              = "acctest-nested-vm-240112225130076500"
  nic_name             = "acctest-nested-nic-240112225130076500"
  disk_name            = "acctest-nested-disk-240112225130076500"
  keyvault_name        = "acctkv240112225130076500"
  nsg_name             = "acctest-nested-nsg-240112225130076500"
  recovery_vault_name  = "acctest-nested-recovery-vault-240112225130076500"
  recovery_site_name   = "acctest-nested-recovery-site-240112225130076500"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsaljmu0"
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
