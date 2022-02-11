package backupvaults

type DppIdentityDetails struct {
	PrincipalId *string `json:"principalId,omitempty"`
	TenantId    *string `json:"tenantId,omitempty"`
	Type        *string `json:"type,omitempty"`
}
