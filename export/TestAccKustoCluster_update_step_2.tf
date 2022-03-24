
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220324160425552452"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                        = "acctestkcgx0yr"
  location                    = azurerm_resource_group.test.location
  resource_group_name         = azurerm_resource_group.test.name
  auto_stop_enabled           = true
  disk_encryption_enabled     = true
  streaming_ingestion_enabled = true
  purge_enabled               = true

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }
}
