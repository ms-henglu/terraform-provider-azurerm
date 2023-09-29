
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-230929065452017623"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230929065452017623"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"

  anti_spyware_profile  = "BestPractice"
  anti_virus_profile    = "BestPractice"
  url_filtering_profile = "BestPractice"
  file_blocking_profile = "BestPractice"
  dns_subscription      = "BestPractice"
  vulnerability_profile = "BestPractice"

  description = "Acceptance Test Desc - 230929065452017623"
}


