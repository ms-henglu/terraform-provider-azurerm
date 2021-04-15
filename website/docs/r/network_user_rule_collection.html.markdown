---
subcategory: "Network"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_network_user_rule_collection"
description: |-
  Manages a Network User Rule Collection.
---

# azurerm_network_user_rule_collection

Manages a Network User Rule Collection.

## Example Usage

```hcl
resource "azurerm_resource_group" "example" {
  name     = "example-network"
  location = "West Europe"
}

resource "azurerm_network_manager" "example" {
  name                = "example-manager"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

resource "azurerm_network_security_user_configuration" "example" {
  name                 = "example-securityconfiguration"
  resource_group_name  = azurerm_resource_group.example.name
  network_manager_name = azurerm_network_manager.example.name
}

resource "azurerm_network_user_rule_collection" "example" {
  name                 = "example"
  resource_group_name  = "example"
  configuration_name   = "example"
  network_manager_name = "example"

  applies_to_groups {
    network_group_id = "TODO"
  }
}
```

## Arguments Reference

The following arguments are supported:

* `applies_to_groups` - (Required) One or more `applies_to_groups` blocks as defined below.

* `configuration_name` - (Required) TODO. Changing this forces a new Network User Rule Collection to be created.

* `name` - (Required) The name which should be used for this Network User Rule Collection. Changing this forces a new Network User Rule Collection to be created.

* `network_manager_name` - (Required) TODO. Changing this forces a new Network User Rule Collection to be created.

* `resource_group_name` - (Required) The name of the Resource Group where the Network User Rule Collection should exist. Changing this forces a new Network User Rule Collection to be created.

---

* `description` - (Optional) TODO.

* `display_name` - (Optional) TODO.

---

A `applies_to_groups` block supports the following:

* `network_group_id` - (Required) The ID of the TODO.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported: 

* `id` - The ID of the Network User Rule Collection.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the Network User Rule Collection.
* `read` - (Defaults to 5 minutes) Used when retrieving the Network User Rule Collection.
* `update` - (Defaults to 30 minutes) Used when updating the Network User Rule Collection.
* `delete` - (Defaults to 30 minutes) Used when deleting the Network User Rule Collection.

## Import

Network User Rule Collections can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_network_user_rule_collection.example C:/Program Files/Git/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resGroup1/providers/Microsoft.Network/networkManagers/networkManager1/securityConfigurations/securityConfiguration1/ruleCollections/ruleCollection1
```
