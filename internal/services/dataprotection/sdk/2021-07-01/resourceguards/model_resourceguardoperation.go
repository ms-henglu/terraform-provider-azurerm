package resourceguards

type ResourceGuardOperation struct {
	RequestResourceType    *string `json:"requestResourceType,omitempty"`
	VaultCriticalOperation *string `json:"vaultCriticalOperation,omitempty"`
}
