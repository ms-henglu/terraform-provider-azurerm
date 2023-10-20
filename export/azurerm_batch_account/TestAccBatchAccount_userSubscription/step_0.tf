
provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azuread_service_principal" "test" {
  display_name = "Microsoft Azure Batch"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231020040628859061"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                            = "batchkvo0rs2"
  location                        = "${azurerm_resource_group.test.location}"
  resource_group_name             = "${azurerm_resource_group.test.name}"
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  tenant_id                       = "ARM_TENANT_ID"

  sku_name = "standard"

  access_policy {
    tenant_id = "ARM_TENANT_ID"
    object_id = "${data.azuread_service_principal.test.object_id}"

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover"
    ]

  }
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatcho0rs2"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"

  pool_allocation_mode = "UserSubscription"

  key_vault_reference {
    id  = "${azurerm_key_vault.test.id}"
    url = "${azurerm_key_vault.test.vault_uri}"
  }
}
