

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024928808812"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl240119024928808812"
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
}


resource "azurerm_dev_test_policy" "import" {
  name                = azurerm_dev_test_policy.test.name
  policy_set_name     = azurerm_dev_test_policy.test.policy_set_name
  lab_name            = azurerm_dev_test_policy.test.lab_name
  resource_group_name = azurerm_dev_test_policy.test.resource_group_name
  threshold           = "999"
  evaluator_type      = "MaxValuePolicy"
}
