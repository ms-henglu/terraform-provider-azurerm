

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

locals {
  rg_name              = "acctest-nested-rg-230316222150663118"
  location             = "West Europe"
  vn_name              = "acctest-nested-vn-230316222150663118"
  ip_name              = "acctest-nested-ip-230316222150663118"
  vm_name              = "acctest-nested-vm-230316222150663118"
  nic_name             = "acctest-nested-nic-230316222150663118"
  disk_name            = "acctest-nested-disk-230316222150663118"
  keyvault_name        = "acctkv230316222150663118"
  nsg_name             = "acctest-nested-nsg-230316222150663118"
  recovery_vault_name  = "acctest-nested-recovery-vault-230316222150663118"
  recovery_site_name   = "acctest-nested-recovery-site-230316222150663118"
  admin_name           = "acctestadmin"
  cert_name            = "acctestcert"
  storage_account_name = "acctestsaa70z1"
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
