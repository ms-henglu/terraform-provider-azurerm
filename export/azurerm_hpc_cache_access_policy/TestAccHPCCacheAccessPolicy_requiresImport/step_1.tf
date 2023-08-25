


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-hpcc-230825024640601568"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VN-230825024640601568"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsub-230825024640601568"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_hpc_cache" "test" {
  name                = "acctest-HPCC-230825024640601568"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_2G"
}


resource "azurerm_hpc_cache_access_policy" "test" {
  name         = "testAccessPolicy"
  hpc_cache_id = azurerm_hpc_cache.test.id
  access_rule {
    scope  = "default"
    access = "rw"
  }
}


resource "azurerm_hpc_cache_access_policy" "import" {
  name         = azurerm_hpc_cache_access_policy.test.name
  hpc_cache_id = azurerm_hpc_cache_access_policy.test.hpc_cache_id
  access_rule {
    scope  = "default"
    access = "rw"
  }
}
