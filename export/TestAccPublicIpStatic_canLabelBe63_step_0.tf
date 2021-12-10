
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024904052483"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-211210024904052483"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "d0cr9z37bewxcxt6k8e8sgu7pq6lbzpq8edmnzmw0r1wpegz7s8jp8nfjqn6sl0"
}
