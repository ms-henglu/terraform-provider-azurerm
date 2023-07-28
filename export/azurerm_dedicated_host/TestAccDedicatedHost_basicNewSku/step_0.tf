

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-compute-230728025312685159"
  location = "West Europe"
}

resource "azurerm_dedicated_host_group" "test" {
  name                        = "acctest-DHG-230728025312685159"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  platform_fault_domain_count = 2
}


resource "azurerm_dedicated_host" "test" {
  name                    = "acctest-DH-230728025312685159"
  location                = azurerm_resource_group.test.location
  dedicated_host_group_id = azurerm_dedicated_host_group.test.id
  sku_name                = "FSv2-Type2"
  platform_fault_domain   = 1
}
