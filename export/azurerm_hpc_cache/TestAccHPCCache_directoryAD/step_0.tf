
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "test" {
  name = "resGroup1"
}

data "azurerm_subnet" "test" {
  resource_group_name  = "resGroup1"
  virtual_network_name = "network1"
  name                 = "subnet1"
}

resource "azurerm_hpc_cache" "test" {
  name                = "acctest-HPC-231016034029717119"
  resource_group_name = data.azurerm_resource_group.test.name
  location            = data.azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = data.azurerm_subnet.test.id
  sku_name            = "Standard_2G"
}
