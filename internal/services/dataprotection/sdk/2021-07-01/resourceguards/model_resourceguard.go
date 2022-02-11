package resourceguards

type ResourceGuard struct {
	AllowAutoApprovals                  *bool                     `json:"allowAutoApprovals,omitempty"`
	Description                         *string                   `json:"description,omitempty"`
	ProvisioningState                   *ProvisioningState        `json:"provisioningState,omitempty"`
	ResourceGuardOperations             *[]ResourceGuardOperation `json:"resourceGuardOperations,omitempty"`
	VaultCriticalOperationExclusionList *[]string                 `json:"vaultCriticalOperationExclusionList,omitempty"`
}
