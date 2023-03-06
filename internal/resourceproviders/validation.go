package resourceproviders

import (
	"github.com/hashicorp/go-azure-helpers/resourceproviders"
	"github.com/hashicorp/terraform-provider-azurerm/internal/features"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/validation"
)

// this is only here to aid testing
var enhancedEnabled = features.EnhancedValidationEnabled()

// EnhancedValidate returns a validation function which attempts to validate the Resource Provider
// against the list of Resource Provider supported by this Azure Environment.
//
// NOTE: this is best-effort - if the users offline, or the API doesn't return it we'll
// fall back to the original approach
func EnhancedValidate(i interface{}, k string) ([]string, []error) {
	if !enhancedEnabled {
		return validation.StringIsNotEmpty(i, k)
	}

	return resourceproviders.EnhancedValidate(i, k)
}
