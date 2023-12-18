---
subcategory: "Container"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_kubernetes_fleet_update_strategy"
description: |-
  Manages a Kubernetes Fleet Update Strategy.
---

<!-- Note: This documentation is generated. Any manual changes will be overwritten -->

# azurerm_kubernetes_fleet_update_strategy

Manages a Kubernetes Fleet Member
.

## Example Usage

```hcl
resource "azurerm_kubernetes_fleet_manager" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  hub_profile {
    dns_prefix = "val-example"
  }
}
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
resource "azurerm_kubernetes_fleet_update_strategy" "example" {
  fleet_id = azurerm_kubernetes_fleet_manager.example.id
  name     = "example"
  strategy {
    stage {
      name = "example"
      group {
        name = "example"
      }
    }
  }
}
```

## Arguments Reference

The following arguments are supported:

* `fleet_id` - (Required) Specifies the Fleet Id within which this Kubernetes Fleet Update Strategy should exist. Changing this forces a new Kubernetes Fleet Update Strategy to be created.

* `name` - (Required) Specifies the name of this Kubernetes Fleet Update Strategy. Changing this forces a new Kubernetes Fleet Update Strategy to be created.

* `strategy` - (Required) A `strategy` block as defined below. Defines the update sequence of the clusters.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported:

* `id` - The ID of the Kubernetes Fleet Update Strategy.

---

## Blocks Reference

### `group` Block


The `group` block supports the following arguments:

* `name` - (Required) 


### `stage` Block


The `stage` block supports the following arguments:

* `group` - (Required) A list of `group` blocks as defined above. 
* `name` - (Required) 
* `after_stage_wait_in_seconds` - (Optional) 


### `strategy` Block


The `strategy` block supports the following arguments:

* `stage` - (Required) A list of `stage` blocks as defined above.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating this Kubernetes Fleet Update Strategy.
* `delete` - (Defaults to 30 minutes) Used when deleting this Kubernetes Fleet Update Strategy.
* `read` - (Defaults to 5 minutes) Used when retrieving this Kubernetes Fleet Update Strategy.
* `update` - (Defaults to 30 minutes) Used when updating this Kubernetes Fleet Update Strategy.

## Import

An existing Kubernetes Fleet Update Strategy can be imported into Terraform using the `resource id`, e.g.

```shell
terraform import azurerm_kubernetes_fleet_update_strategy.example /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.ContainerService/fleets/{fleetName}/updateStrategies/{updateStrategyName}
```

* Where `{subscriptionId}` is the ID of the Azure Subscription where the Kubernetes Fleet Update Strategy exists. For example `12345678-1234-9876-4563-123456789012`.
* Where `{resourceGroupName}` is the name of Resource Group where this Kubernetes Fleet Update Strategy exists. For example `example-resource-group`.
* Where `{fleetName}` is the name of the Fleet. For example `fleetValue`.
* Where `{updateStrategyName}` is the name of the Update Strategy. For example `updateStrategyValue`.