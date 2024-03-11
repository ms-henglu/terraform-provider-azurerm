


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-240311032721749222"
  location = "West Europe"

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
    "SkipNRMSNSG"   = "true"
  }
}




resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240311032721749222"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
  }
}


resource "azurerm_netapp_account" "import" {
  name                = azurerm_netapp_account.test.name
  location            = azurerm_netapp_account.test.location
  resource_group_name = azurerm_netapp_account.test.resource_group_name

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
  }
}
