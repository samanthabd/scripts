<# Overview
(running via batch from command line:)
sass-new.bat [partial name] [module name (opt)]

Will create a new scss in the specified module and update the _index file.
If the module or index file doesn't exist, it will create them.
If no module is specified, will default to 'components'.
New partial will include @import statement for variables and opening class selector. 

Relies on the following assumptions:
- a 'scss' subdirectory exists, and only one
- scss subdirectory architecture is similar to 7-1 pattern 
  (https://sass-guidelin.es/#the-7-1-pattern)
- 'scss/components' exists and should be default location of new partials
- 'scss/abstracts' exists, is one level up from the new partial's containing module

------- Examples --------
    * = new 
    ~ = modified
  
  sass-new.bat button contact-page
    --> scss
        ├─ abstracts
        ├─ base
        ├─ components
      * └─ contact-page
      *      ├─ _index.scss 
      *      └─ _button.scss 

  sass-new.bat button 
    --> scss
          ├─ abstracts
          ├─ base
          └─ components
        ~      ├─ _index.scss
        *      └─ _button.scss
#>

$currentDirectory = Get-Location
$scssFolder = $null
$partialName = $args[0]
$moduleName = $args[1] ?? 'components'
$indexContent =  "@forward '$partialName';"
$partialContent = "@use '../abstracts' as *;`n`n.$partialName {`n`n`n}"
$exitMessage

<# Find the 'scss' folder
  Searches recursively to give some flexibility for different types of project
  architecture, but limited depth and excluded node_modules
#>
$scssFolder = Get-ChildItem -Path $currentDirectory -Directory -Exclude .*,node_modules -Recurse -Depth 4 -Filter "scss" |  Select -Expand  FullName

if (-not($scssFolder)) {
  Write-Host "Could not find '/scss'. Exiting without creating new module. "
  Return
}

$modulePath = "$scssFolder/\$moduleName"

if (-not(Test-Path -Path $modulePath)) {
  <# Check module folder exists, and if not then make it and _index.scss #>
  $modulePath =  New-Item -Path $modulePath -ItemType Directory | Select -Expand FullName 
  
  $moduleIndex = New-Item -Path "$modulePath/\_index.scss" -ItemType File | Select -Expand FullName 

  $exitMessage = "You added a new module folder: $moduleName.`nMake sure you include it in an entrypoint stylesheet with @use"

} else {

<# If the module folder already exists, make sure it has an _index file  #>
  $moduleIndex = Get-ChildItem  -Path $modulePath -Filter "_index.scss"  |  Select -Expand FullName

  if (-not($moduleIndex)) {
    $moduleIndex =  New-Item -Path "$modulePath/\_index.scss"  -ItemType File  | Select -Expand FullName 

    $exitMessage = "The $moduleName module did not have an index file.`nIf it contains other partials, you may want to @forward them.`nMake sure the module is included in an entrypoint stylesheet with @use."
  }
}

$partialPath = "$modulePath/\_$partialName.scss"

<# Append _index with @forward statement #>
Add-Content -Path $moduleIndex -Value $indexContent;

<# Create new partial with variables @import and opening tag #>
New-Item -Path $partialPath -ItemType File | Add-Content -Value $partialContent

if($exitMessage){ Write-Host $exitMessage}