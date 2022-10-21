
provider "azurerm" {
  features {
    app_configuration {
      recover_soft_deleted = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-221021030815031089"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                       = "testaccappconf221021030815031089"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  sku                        = "standard"
  soft_delete_retention_days = 1
}
