
provider "azurerm" {
  features {
    app_configuration {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted         = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-231218071141874036"
  location = "West Europe"
}


