
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "acctestRG-kusto-221028172316104639"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkc06hya"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa06hya"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_kusto_cluster_managed_private_endpoint" "test" {
  name                         = "acctestmpe221028172316104639"
  resource_group_name          = azurerm_resource_group.rg.name
  cluster_name                 = azurerm_kusto_cluster.test.name
  private_link_resource_id     = azurerm_storage_account.test.id
  private_link_resource_region = azurerm_storage_account.test.location
  group_id                     = "blob"
  request_message              = "Please Approve"
}
