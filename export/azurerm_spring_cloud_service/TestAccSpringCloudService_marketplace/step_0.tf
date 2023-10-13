
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-231013044316696522"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-231013044316696522"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"

  marketplace {
    plan      = "asa-ent-hr-mtr"
    publisher = "vmware-inc"
    product   = "azure-spring-cloud-vmware-tanzu-2"
  }
}
