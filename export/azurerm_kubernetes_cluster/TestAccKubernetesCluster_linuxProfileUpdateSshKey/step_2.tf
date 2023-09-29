
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230929064631542747"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230929064631542747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230929064631542747"

  linux_profile {
    admin_username = "acctestuser230929064631542747"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDuiot/laqt5Bxhy0Kaj+g9GqBkr+PEjB18ty59MZC+QXmG7pgOb98FT3BrHUoCtqWWqUASMyMjKIL1fR9HCsV5hJdiecuksldGoWIg9Idr6+5hYDBpPJrm/JHbQBf259YfEi8pQtzAL1ppAv/FqL//MZo2vztnrPi5yDWl+G7ItzF5XeURPtG9DC97T9stUOeLl8bqM4X2ZtydsCkoCia/tajBcp1dFf13kZL9SCsxW452fgXGipx/LvSQQAFcT+xt6mZSgFfSCHUZm4JnxLjSweefRpIOxkO09QS4BlK1MUeBx/EL1Cxv4ql0Uu5x9m64G8E3m1PIJabLp/8Dw84d"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
