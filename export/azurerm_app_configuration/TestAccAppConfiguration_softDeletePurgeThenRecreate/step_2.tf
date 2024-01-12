
provider "azurerm" {
  features {
    app_configuration {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted         = false
    }
  }
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-240112033751740458"
  location = "West Europe"
}
