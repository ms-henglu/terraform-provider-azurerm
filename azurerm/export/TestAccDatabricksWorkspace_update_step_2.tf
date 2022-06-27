
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-db-220627131757168849"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "test" {
  name                        = "acctestDBW-220627131757168849"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  sku                         = "standard"
  managed_resource_group_name = "acctestRG-DBW-220627131757168849-managed"

  tags = {
    Pricing = "Standard"
  }

  custom_parameters {
    no_public_ip = false
  }
}
