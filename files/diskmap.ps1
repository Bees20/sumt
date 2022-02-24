param ($drivenum, $driveletter, $drivelabel)
Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle GPT -PassThru

New-Partition -DiskNumber $drivenum -DriveLetter $driveletter -UseMaximumSize| Format-Volume -FileSystem NTFS -NewFileSystemLabel $drivelabel

