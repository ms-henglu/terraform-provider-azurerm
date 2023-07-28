
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-aks-230728025358798574"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "test" {
  name                = "acctestaks230728025358798574"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "acctestaks230728025358798574"

  linux_profile {
    admin_username = "acctestuser230728025358798574"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqaZoyiz1qbdOQ8xEf6uEu1cCwYowo5FHtsBhqLoDnnp7KUTEBN+L2NxRIfQ781rxV6Iq5jSav6b2Q8z5KiseOlvKA/RF2wqU0UPYqQviQhLmW6THTpmrv/YkUCuzxDpsH7DUDhZcwySLKVVe0Qm3+5N2Ta6UYH3lsDf9R9wTP2K/+vAnflKebuypNlmocIvakFWoZda18FOmsOoIVXQ8HWFNCuw9ZCunMSN62QGamCe3dL5cXlkgHYv7ekJE15IA9aOJcM7e90oeTqo+7HTcWfdu0qQqPWY5ujyMw/llas8tsXY85LFqRnr3gJ02bAscjc477+X+j/gkpFoN1QEmt terraform@demo.tld"
    }
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }

  identity {
    type = "SystemAssigned"
  }
}
