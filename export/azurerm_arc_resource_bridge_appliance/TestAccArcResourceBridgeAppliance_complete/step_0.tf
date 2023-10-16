


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-231016033342433857"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-231016033342433857"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEA5FNC79CuWQ9WlkGdd11LiYBZ2lwt19LpEv2zuj/4vlGX64QczzMczEGml3iFFWCvKl5kHDeaFmNal+F9MMII5mlr8pXQ8Jvy2JO15I4igAzIKYAWFQAJ3Yu9gAZ1qNcyhXG5y4N0cGkEfdQob46DBUfCKPGeU0ae7jPYnDUM8cOfoyXedoh/0F9r2t6CSnlER67CmPExdZ1fRosxu3B5uC43nrkOOI+zn0kEQxSp9lW3JZSbVSM8khobfj6GebYIE/6hqc5b9xBtC51B62P3RnlBN7WPTXSoSTvGt5PRju1MGBV5P4zXJQUvv88OwZCdIcQpO13FYiXSlPsr1F+172SfE6NK5UHzcL/BQcwMd//rl1FjwjbFELgqhwHYtb6KgqW8R8kd+cqQYLuKb0GgLoaguBrbd7qoAMrqytTGN/sU55aMRBON/xhJXZ7EKbhD8hj4yNDNO+UuTxXD11R6n8x3dBUYOwEpJYcsyUgNyqSe5A+OkdzK44RNJvVXmzieZmgjSUGwY6j1xxpNelPg+ZdsdE1X9tNsaOPqwvAghZxEDJOIo5g1wpnYGpohjZbLzHaTDxzlkMBQ9pALkXHPBUYij83NqOUuSWChqIqztSONP8+4GM1R9WapHbsnRxOwAyybx9MGhnNpXLJsZ+vXZJwq2/gMy8JpUTozsdIElAsCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
