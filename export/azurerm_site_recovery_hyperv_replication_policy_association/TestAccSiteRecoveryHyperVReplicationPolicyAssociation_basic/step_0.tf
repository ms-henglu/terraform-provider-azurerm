

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-240119022723234090"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-240119022723234090"
  ip_name              = "acctest-nested-ip-240119022723234090"
  vm_name              = "acctest-nested-vm-240119022723234090"
  nic_name             = "acctest-nested-nic-240119022723234090"
  disk_name            = "acctest-nested-disk-240119022723234090"
  keyvault_name        = "acctkv240119022723234090"
  nsg_name             = "acctest-nested-nsg-240119022723234090"
  recovery_vault_name  = "acctest-nested-recovery-vault-240119022723234090"
  recovery_site_name   = "acctest-nested-recovery-site-240119022723234090"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsa6hp8p"
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
