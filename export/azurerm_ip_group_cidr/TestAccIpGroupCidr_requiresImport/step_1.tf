

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-240112224958153694"
  location = "West Europe"
}

resource "azurerm_ip_group" "test" {
  name                = "acceptanceTestIpGroup1"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    env = "prod"
  }

  lifecycle {
    ignore_changes = ["cidrs"]
  }
}

resource "azurerm_ip_group_cidr" "test" {
  ip_group_id = azurerm_ip_group.test.id
  cidr        = "10.0.0.0/24"
}




resource "azurerm_ip_group_cidr" "import" {
  ip_group_id = azurerm_ip_group_cidr.test.ip_group_id
  cidr        = azurerm_ip_group_cidr.test.cidr
}
