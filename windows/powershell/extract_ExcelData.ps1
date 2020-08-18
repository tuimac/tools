#initial variable
$scriptpath = $MyInvocation.MyCommand.Path
$textpath = "${scriptpath}\extracted.txt"
$row = 3
$column = "A"

try{
    #start excel process
    $excel = New-Object -ComObject Excel.Application

    #running excel background
    $excel.Visible = $false

    #extract Excel object
    $book = $excel.Workbooks.Open($scriptpath)

    #extract sheetname(direct sheetnum or sheetname to the "Item" parameter)
    $sheetname = $sheet = $excel.Worksheets.Item(1)

}catch [Exception] {
    Write-Host "you got error!!"
    Exit 1
}

function data_to_text([ref]$sheetname) {
    
    
}

function colum_to_num($column){
    $array = $column.ToCharArray() | %{[int][char]$_}
    $numofcolumn = 0
    for ($i = 0; $i -lt $array.length; $i++){
        $numofcolumn = ($array[$i] - 64) + ($i * 26)
    }
    return $numofcolumn
}
