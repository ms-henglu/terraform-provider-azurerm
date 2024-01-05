

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240105064539121982"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                = "acctestaccoy94z"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_security_center_storage_defender" "test" {
  storage_account_id                          = azurerm_storage_account.test.id
  override_subscription_settings_enabled      = true
  malware_scanning_on_upload_enabled          = true
  malware_scanning_on_upload_cap_gb_per_month = 4
  sensitive_data_discovery_enabled            = true
}
