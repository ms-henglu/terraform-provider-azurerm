
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728025647174980"
  location = "West Europe"
}

resource "azurerm_dns_zone" "test" {
  name                = "acctestzone230728025647174980.com"
  resource_group_name = azurerm_resource_group.test.name

  tags = {
    environment = "staging"
  }
}
