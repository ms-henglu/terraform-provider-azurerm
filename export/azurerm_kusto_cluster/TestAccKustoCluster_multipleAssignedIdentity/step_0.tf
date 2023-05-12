
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010846224447"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest6gr7y"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc6gr7y"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
}
