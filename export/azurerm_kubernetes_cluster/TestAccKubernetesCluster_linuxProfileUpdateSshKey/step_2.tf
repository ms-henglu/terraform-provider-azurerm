
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-240112224211755239"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks240112224211755239"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks240112224211755239"

  linux_profile {
    admin_username = "acctestuser240112224211755239"

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
