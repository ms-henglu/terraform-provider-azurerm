
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-231016034408439171"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-231016034408439171"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate"    = "2022-07-08T23:50:21Z",
    "SkipASMAzSecPack" = "true"
  }
}

resource "azurerm_netapp_pool" "test" {
  name                = "acctest-NetAppPool-231016034408439171"
  account_name        = azurerm_netapp_account.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_level       = "Standard"
  size_in_tb          = 15
  qos_type            = "Auto"

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
    "FoO"           = "BaR"
  }
}
