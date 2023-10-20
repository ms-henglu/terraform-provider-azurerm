
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231020041948030034"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctcq1i7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  azure_files_authentication {
    directory_type = "AD"
    active_directory {
      storage_sid         = "S-1-5-21-2400535526-2334094090-2402026252-0012"
      domain_name         = "adtest.com"
      domain_sid          = "S-1-5-21-2400535526-2334094090-2402026252-0012"
      domain_guid         = "aebfc118-9fa9-4732-a21f-d98e41a77ae1"
      forest_name         = "adtest.com"
      netbios_domain_name = "adtest.com"
    }
  }

  tags = {
    environment = "production"
  }
}
