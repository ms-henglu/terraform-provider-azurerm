


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-VMSS-211001020609167629"
  location = "West Europe"
}


resource "azurerm_orchestrated_virtual_machine_scale_set" "test" {
  name                = "acctestVMO-211001020609167629"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  platform_fault_domain_count = 1

  zones = ["1"]

  tags = {
    ENV = "Test"
  }
}


resource "azurerm_orchestrated_virtual_machine_scale_set" "import" {
  name                = azurerm_orchestrated_virtual_machine_scale_set.test.name
  location            = azurerm_orchestrated_virtual_machine_scale_set.test.location
  resource_group_name = azurerm_orchestrated_virtual_machine_scale_set.test.resource_group_name

  platform_fault_domain_count = azurerm_orchestrated_virtual_machine_scale_set.test.platform_fault_domain_count
  single_placement_group      = azurerm_orchestrated_virtual_machine_scale_set.test.single_placement_group
}
