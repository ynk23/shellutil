#!/usr/bin/php
<?php
require_once 'Classes/PHPExcel.php';
require_once 'Classes/PHPExcel/Calculation.php';
require_once 'Classes/PHPExcel/Cell.php';


function usage() {
  echo "insertexcel.php --row -f excel_file csv_value\n";
  exit(1);
}

$excel_file = '';
$csv_val    = '';
$rowinsert  = null;

array_shift($argv);	// skip head 

if( count($argv) == 0){
  usage();              // exit
}

while(count($argv) >= 1){

  switch($argv[0]){
    case '--row':
      $rowinsert = true;
      break;
    case '-f':
      $excel_file = $argv[1];
      array_shift($argv);
      break;
    default:
      $csv_val = $argv[0];
      break 2;
  }
  array_shift($argv);
}

if ( empty($rowinsert) || empty($excel_file) || empty($csv_val) ) {
  usage();  // exit
}

try{
  $book = PHPExcel_IOFactory::load($excel_file);
}catch(Exception $e){
  fputs(STDERR, "ERROR: excel file does not open out.\n");
  exit(1);
}
$sheet = $book->getSheet(0);

// get max size of row
$row_max = $sheet->getHighestRow();

// insert row
$row = $row_max+1;
$sheet->insertNewRowBefore($row, 1);

$vals = explode(",", $csv_val);
for ($col = 0 ; $col < count($vals); $col++){
  $sheet->setCellValueByColumnAndRow($col, $row, $vals[$col]);
}

// save Excel 2007 xlsx
$writer = PHPExcel_IOFactory::createWriter($book, 'Excel2007');
$writer->save($excel_file);
fputs(STDOUT, "saved {$excel_file}\nconvert successfull !\n");
