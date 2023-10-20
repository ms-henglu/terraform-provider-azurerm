

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-231020041320203602"
  location = "West Europe"
}

resource "azurerm_lb" "test" {
  name                = "acctest-loadbalancer-231020041320203602"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}


resource "azurerm_lb" "import" {
  name                = azurerm_lb.test.name
  location            = azurerm_lb.test.location
  resource_group_name = azurerm_lb.test.resource_group_name

  tags = {
    Environment = "production"
    Purpose     = "AcceptanceTests"
  }
}
