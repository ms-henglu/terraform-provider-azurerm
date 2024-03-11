

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
  name     = "acctestRG-netapp-240311032721746442"
  location = "West Europe"

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
    "SkipNRMSNSG"   = "true"
  }
}




resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240311032721746442"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  active_directory {
    username            = "aduser"
    password            = "aduserpwd"
    smb_server_name     = "SMBSERVER"
    dns_servers         = ["1.2.3.4"]
    domain              = "westcentralus.com"
    organizational_unit = "OU=FirstLevel"
  }

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
    "FoO"           = "BaR"
  }
}
