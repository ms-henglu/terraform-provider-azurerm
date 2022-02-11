package backupvaults

type PatchResourceRequestInput struct {
	Identity *DppIdentityDetails `json:"identity,omitempty"`
	Tags     *map[string]string  `json:"tags,omitempty"`
}
