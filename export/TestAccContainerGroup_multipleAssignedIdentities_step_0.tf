
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210825031527813634"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"

  name = "acctestdb0hx"
}

resource "azurerm_container_group" "test" {
  name                = "acctestcontainergroup-210825031527813634"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_address_type     = "public"
  os_type             = "Linux"

  container {
    name   = "hw"
    image  = "microsoft/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "0.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = ["${azurerm_user_assigned_identity.test.id}"]
  }

  tags = {
    environment = "Testing"
  }
}
