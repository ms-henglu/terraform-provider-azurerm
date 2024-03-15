


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240315122643979325"
  location = "West Europe"
}

resource "azurerm_kubernetes_fleet_manager" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestkfm-240315122643979325"
  resource_group_name = azurerm_resource_group.test.name
  hub_profile {
    dns_prefix = "val-240315122643979325"
  }
}


resource "azurerm_kubernetes_fleet_update_strategy" "test" {
  name                        = "acctestfus-240315122643979325"
  kubernetes_fleet_manager_id = azurerm_kubernetes_fleet_manager.test.id
  stage {
    name = "acctestfus-240315122643979325"
    group {
      name = "acctestfus-240315122643979325"
    }
  }

}
