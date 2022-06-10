

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-compute-220610022336650925"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctest-DHG-220610022336650925"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}


resource "azurerm_dedicated_host" "test" {
  name                    = "acctest-DH-220610022336650925"
  location                = azurerm_resource_group.test.location
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  sku_name                = "DSv3-Type1"
  platform_fault_domain   = 1
  license_type            = "None"
}
