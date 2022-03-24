# dot-source files
Get-ChildItem .\scripts -ErrorAction 'Continue' | ForEach-Object {
    . .\scripts\$_
}