
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064809965126"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230929064809965126"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_policy" "test" {
  name                = "LabVmCount"
  policy_set_name     = "default"
  lab_name            = azurerm_dev_test_lab.test.name
  resource_group_name = azurerm_resource_group.test.name
  threshold           = "999"
  evaluator_type      = "MaxValuePolicy"
  description         = "Aloha this is the max number of VM's'"

  tags = {
    "Acceptance" = "Test"
  }
}
