

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-230915023859029667"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-230915023859029667"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
  }
}


resource "azurerm_netapp_account" "import" {
  name                = azurerm_netapp_account.test.name
  location            = azurerm_netapp_account.test.location
  resource_group_name = azurerm_netapp_account.test.resource_group_name

  tags = {
    "CreatedOnDate" = "2022-07-08T23:50:21Z",
  }
}
