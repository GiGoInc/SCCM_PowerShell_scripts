# Pull out the matching GUID and capture both stdout and stderr.
}
$result
# Pull out the matching GUID and capture both stdout and stderr.
$result = powercfg -s "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" 2>&1
# If there were any problems, show the error.
if ( $LASTEXITCODE -ne 0)
{
$result
}
