
provider "azurerm" {
  features {}
}

data "azurerm_platform_image" "test" {
  location  = "West Europe"
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "16.04-LTS"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064556847449"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-230929064556847449"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  os_type              = "Linux"
  create_option        = "FromImage"
  disk_size_gb         = 0
  image_reference_id   = data.azurerm_platform_image.test.id
  storage_account_type = "Standard_LRS"
}
