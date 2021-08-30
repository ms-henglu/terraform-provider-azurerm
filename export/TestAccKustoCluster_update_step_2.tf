
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210830084118699482"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                    = "acctestkcmm971"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  enable_disk_encryption  = true
  enable_streaming_ingest = true
  enable_purge            = true

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}
