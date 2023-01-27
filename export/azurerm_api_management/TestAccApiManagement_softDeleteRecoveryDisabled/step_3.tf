
provider "azurerm" {
  features {
    api_management {
      recover_soft_deleted = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230127044928844755"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230127044928844755"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}
