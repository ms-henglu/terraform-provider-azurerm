
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-230922060459226812"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                    = "acctestass230922060459226812"
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
