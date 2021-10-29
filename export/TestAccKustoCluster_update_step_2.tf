
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015733582039"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                    = "acctestkc906xl"
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
