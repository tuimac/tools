$array = $column.ToCharArray() | %{[int][char]$_}
$numofcolumn = 0
for ($i = 0; $i -lt $array.length; $i++){
    $numofcolumn = ($array[$i] - 64) + ($i * 26)
}
