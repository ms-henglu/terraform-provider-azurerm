
provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults = false
    }
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825044909173965"
  location = "West Europe"
}
