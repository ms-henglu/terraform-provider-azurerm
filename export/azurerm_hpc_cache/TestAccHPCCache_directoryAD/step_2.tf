
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
  name                = "acctest-HPC-230825024640603099"
  resource_group_name = data.azurerm_resource_group.test.name
  location            = data.azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = data.azurerm_subnet.test.id
  sku_name            = "Standard_2G"
  directory_active_directory {
    dns_primary_ip      = "ARM_TEST_HPC_AD_PRIMARY_DNS"
    domain_name         = "ARM_TEST_HPC_AD_DOMAIN_NAME"
    cache_netbios_name  = "ARM_TEST_HPC_AD_CACHE_NET_BIOS_NAME"
    domain_netbios_name = "ARM_TEST_HPC_AD_DOMAIN_NET_BIOS_NAME"
    username            = "ARM_TEST_HPC_AD_USERNAME"
    password            = "ARM_TEST_HPC_AD_PASSWORD"
  }
}
