
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230929065807186004"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acct6y81v"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  azure_files_authentication {
    directory_type = "AADKERB"
    active_directory {
      domain_name = "adtest2.com"
      domain_guid = "13a20c9a-d491-47e6-8a39-299e7a32ea27"
    }
  }

  tags = {
    environment = "production"
  }

  lifecycle {
    ignore_changes = [
      azure_files_authentication.0.active_directory.0.storage_sid,
      azure_files_authentication.0.active_directory.0.domain_sid,
      azure_files_authentication.0.active_directory.0.forest_name,
      azure_files_authentication.0.active_directory.0.netbios_domain_name,
    ]
  }
}
