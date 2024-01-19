


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-compute-240119021734427178"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctest-DHG-240119021734427178"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}


resource "azurerm_dedicated_host" "test" {
  name                    = "acctest-DH-240119021734427178"
  location                = azurerm_resource_group.test.location
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  sku_name                = "DSv3-Type3"
  platform_fault_domain   = 1
}

resource "azurerm_dedicated_host" "import" {
  name                    = azurerm_dedicated_host.test.name
  location                = azurerm_dedicated_host.test.location
  dedicated_host_group_id = azurerm_dedicated_host.test.dedicated_host_group_id
  sku_name                = azurerm_dedicated_host.test.sku_name
  platform_fault_domain   = azurerm_dedicated_host.test.platform_fault_domain
}
