
provider "azurerm" {
  features {
    app_configuration {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = false
    }
  }
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230922060514883228"
  location = "West Europe"
}
