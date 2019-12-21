$scriptpath = Split-Path $MyInvocation.MyCommand.Path -Parent

$excel = New-Object -ComObject Excel.Application

$excel.Workbooks.Add() | %{
    
    $_.Worksheets.Item(1) |  %{
        
        $_.Cells.Item(1, 1) = "A1"
        $_.Cells.Item(1, 2) = "B1"
        $_.Cells.Item(2, 1) = "A2"
        $_.Cells.Item(2, 2) = "B2"
    }

    $_.SaveAs("${scriptpath}\test.xlsx")
}

$excel.Quit()
[System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null
