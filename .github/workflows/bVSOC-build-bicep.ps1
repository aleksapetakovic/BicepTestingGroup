#############################
# Andrea Hofer | 06.01.2023 #
# CRQ: xxx                  #
#############################
$strCsvPath = "$($Env:rootDirectory)\.sentinel\bVSOC-build-bicep.csv"

"load already built files from file $strCsvPath"
$arrDeployedFiles = Import-Csv $strCsvPath -Delimiter ","


$arrBicepFiles = Get-ChildItem -Filter *.bicep -Recurse
if ($null -eq $arrBicepFiles) {
    "no bicep files found"
}

"checking az bicep command"
az bicep --help

$arrNewRows =  @()
ForEach($objFile in $arrBicepFiles){
    $strOut = $null
    $objFileHash = $null
    $objDeployedFile = $null

    $objFileHash = Get-FileHash -Algorithm SHA256 -Path $objFile

    $objDeployedFile = $arrDeployedFiles | Where-Object {$_.sha256Hash -eq $objFileHash.Hash}

    "### processing $($objFile.FullName)"

    If($objFile.Name.StartsWith("_template"))
    {
        "file $($objFile.Name) is a template -> file will be ignored"

    }Else{

        If($objDeployedFile){
            "file $($objFile.Name) with sha256 hash $($objFileHash.Hash) was already built on $($objDeployedFile.lastActionDate)"
        }
        Else{
            "file $($objFile.Name) was not built before -> build file"
            $strOut = az bicep build --file $objFile.FullName
            If($LastExitCode -ne 0){
                "unable to build file"
                $strOut
            }
            Else{
                "file built. add it to the csv file"
                
                $objNewRow = [pscustomobject]@{ 
                    fileFullName = $($objFile.FullName)
                    sha256Hash = $($objFileHash.Hash)
                    lastActionDate = $(Get-Date -format "dd.MM.yyyy HH:mm:ss")
                    }
                $arrNewRows += $objNewRow
                "done"

            }
        }
    }
    "---------------------------------"
}
"export the csv file"
$arrNewRows | Export-Csv -Delimiter "," -NoClobber -NoTypeInformation -Append $strCsvPath
"done"


