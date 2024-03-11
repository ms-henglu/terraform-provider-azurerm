
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031929037564"
  location = "West Europe"
}

resource "azurerm_dev_center" "test" {
  name                = "acctdc-240311031929037564"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_dev_center_catalog" "test" {
  name                = "acctest-catalog-240311031929037564"
  resource_group_name = azurerm_resource_group.test.name
  dev_center_id       = azurerm_dev_center.test.id
  catalog_github {
    branch            = "foo"
    path              = ""
    uri               = "https://github.com/am-lim/deployment-environments.git"
    key_vault_key_url = "https://amlim-kv.vault.azure.net/secrets/envTest/0a79f15246ce4b35a13957367b422cab"
  }
}
