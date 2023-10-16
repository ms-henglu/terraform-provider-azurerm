
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-231016033253010336"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                    = "acctestass231016033253010336"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  sku                     = "B1"
  enable_power_bi_service = false

  ipv4_firewall_rule {
    name        = "test1"
    range_start = "92.123.234.11"
    range_end   = "92.123.234.12"
  }
}
