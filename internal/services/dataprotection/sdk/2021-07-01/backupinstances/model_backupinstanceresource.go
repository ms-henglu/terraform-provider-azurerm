package backupinstances

type BackupInstanceResource struct {
	Id         *string         `json:"id,omitempty"`
	Name       *string         `json:"name,omitempty"`
	Properties *BackupInstance `json:"properties,omitempty"`
	SystemData *SystemData     `json:"systemData,omitempty"`
	Type       *string         `json:"type,omitempty"`
}
