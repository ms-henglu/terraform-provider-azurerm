

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
  name     = "acctestRG-netapp-240311032721740896"
  location = "West Europe"

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
    "SkipNRMSNSG"   = "true"
  }
}




resource "azurerm_user_assigned_identity" "test" {
  name                = "user-assigned-identity-240311032721740896"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    CreatedOnDate = "2023-10-03T19:58:43.6509795Z"
  }
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240311032721740896"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id
    ]
  }

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z"
  }
}
