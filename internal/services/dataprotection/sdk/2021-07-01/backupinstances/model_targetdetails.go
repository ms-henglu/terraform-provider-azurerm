package backupinstances

type TargetDetails struct {
	FilePrefix                string                    `json:"filePrefix"`
	RestoreTargetLocationType RestoreTargetLocationType `json:"restoreTargetLocationType"`
	Url                       string                    `json:"url"`
}
