
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204093137596201"
  location = "West Europe"
}

resource "azurerm_kusto_cluster" "test" {
  name                = "acctestkckgwd0"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    name     = "Dev(No SLA)_Standard_D11_v2"
    capacity = 1
  }

  trusted_external_tenants = [data.azurerm_client_config.current.tenant_id]
}
