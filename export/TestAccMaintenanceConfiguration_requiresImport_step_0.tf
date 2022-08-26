
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-220826002945976558"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                = "acctest-MC220826002945976558"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope               = "SQLDB"
  visibility          = "Custom"
}
