
provider "azurerm" {
  features {
    api_management {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181202661363"
  location = "West Europe"
}
