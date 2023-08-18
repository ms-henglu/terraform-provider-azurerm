
provider "azurerm" {
  features {
    api_management {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230818023425146107"
  location = "West Europe"
}
