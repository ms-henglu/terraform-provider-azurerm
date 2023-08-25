
provider "azurerm" {
  features {
    app_configuration {
      recover_soft_deleted = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230825023953800280"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                       = "testaccappconf230825023953800280"
  resource_group_name        = azurerm_resource_group.test.name
  location                   = azurerm_resource_group.test.location
  sku                        = "standard"
  soft_delete_retention_days = 1
}
