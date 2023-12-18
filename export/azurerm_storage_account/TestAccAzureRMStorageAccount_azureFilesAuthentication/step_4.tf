
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-231218072636016581"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "unlikely23exst2acctne4hx"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  azure_files_authentication {
    directory_type = "AD"
    active_directory {
      storage_sid         = "S-1-5-21-2400535526-2334094090-2402026252-1112"
      domain_name         = "adtest2.com"
      domain_sid          = "S-1-5-21-2400535526-2334094090-2402026252-1112"
      domain_guid         = "13a20c9a-d491-47e6-8a39-299e7a32ea27"
      forest_name         = "adtest2.com"
      netbios_domain_name = "adtest2.com"
    }
  }

  tags = {
    environment = "production"
  }
}
