

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-230616075201615701"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-230616075201615701"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-230616075201615701"
  account_name        = azurerm_netapp_account.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_level       = "Standard"
  size_in_tb          = 4

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
  }
}

resource "azurerm_netapp_pool" "import" {
  name                = azurerm_netapp_pool.test.name
  location            = azurerm_netapp_pool.test.location
  resource_group_name = azurerm_netapp_pool.test.resource_group_name
  account_name        = azurerm_netapp_pool.test.account_name
  service_level       = azurerm_netapp_pool.test.service_level
  size_in_tb          = azurerm_netapp_pool.test.size_in_tb
}
