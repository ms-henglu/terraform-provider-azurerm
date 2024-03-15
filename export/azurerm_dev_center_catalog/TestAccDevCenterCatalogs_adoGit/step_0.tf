
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240315122858840201"
  location = "West Europe"
}

resource "azurerm_dev_center" "test" {
  name                = "acctdc-240315122858840201"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_dev_center_catalog" "test" {
  name                = "acctest-catalog-240315122858840201"
  resource_group_name = azurerm_resource_group.test.name
  dev_center_id       = azurerm_dev_center.test.id
  catalog_adogit {
    branch            = "main"
    path              = "/template"
    uri               = "https://amlim@dev.azure.com/amlim/testCatalog/_git/testCatalog"
    key_vault_key_url = "https://amlim-kv.vault.azure.net/secrets/ado/6279752c2bdd4a38a3e79d958cc36a75"
  }
}
