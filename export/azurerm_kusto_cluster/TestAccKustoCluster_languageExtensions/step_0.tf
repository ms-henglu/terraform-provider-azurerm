
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230616074920141397"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkciddzg"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Standard_E4d_v4"
    capacity = 2
  }

  language_extensions = ["PYTHON", "R"]
}
