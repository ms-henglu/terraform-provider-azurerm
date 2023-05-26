
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085303887115"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                        = "acctestkc9hz6m"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  auto_stop_enabled           = true
  disk_encryption_enabled     = true
  streaming_ingestion_enabled = true
  purge_enabled               = true
  public_ip_type              = "DualStack"

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}
