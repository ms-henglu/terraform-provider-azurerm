
provider "azurerm" {
  features {
    api_management {
      purge_soft_delete_on_destroy = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015200961349"
  location = "West Europe"
}
