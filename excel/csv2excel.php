#!/usr/bin/php
<?php
// csv2excel.php
//    this script follows excel2csv.php
//

declare(encoding="UTF-8");

require_once 'Classes/PHPExcel.php';
require_once 'Classes/PHPExcel/IOFactory.php';
require_once 'Classes/PHPExcel/Calculation.php';
require_once 'Classes/PHPExcel/Cell.php';

function usage()
{
  echo "usage :\n";
  echo "  csv2excel.php [--delimiter delimiter] [--enclosure enclosure] -f csv_file \n";
  echo "    delimiter : default ',' ( must be a single character )\n";
  echo "    enclosure : default '' ( nust be a single character )\n";
  exit(1);
}

// parse argument
$csv_file = '';
$delimiter = '';
$enclosure = '';

array_shift($argv);	// skip head ( csv2excel )

if( count($argv) == 0){
  usage();		// exit
}

while(count($argv) >= 1){
  switch($argv[0]){
    case '-f':
      $csv_file = $argv[1];
      array_shift($argv);
      break;
    case '--delimiter':
      $delimiter = $argv[1];
      array_shift($argv);
      break;
    case '--enclosure':
      $enclosure = $argv[1];
      array_shift($argv);
      break;
    default:
      fputs(STDERR, "ERROR: Unknown option. [{$argv[0]}]\n");
        usage();        // exit
  }
  array_shift($argv);
}

// input check
if(empty($csv_file)){
  fputs(STDERR, "ERROR: Input csv file is empty.\n");
  exit(1);
}else{
  $pi = pathinfo($csv_file);
  switch($pi['extension']){
    case 'csv':
      break;
    default:
      fputs(STDERR, "ERROR: Unkown extension [{$pi['extension']}]. (available: csv)\n");
      exit(1);
  }
}
if(empty($delimiter)){
  $delimiter = ',';
}
if(strlen($delimiter) > 1){
  fputs(STDERR, "ERROR: delimiter must be a single character\n");
  exit(1);
}
if(strlen($enclosure) > 1){
  fputs(STDERR, "ERROR: enclosure must be a single character\n");
  exit(1);
}

// get path info
$pi = pathinfo($csv_file);
$csv_dir  = $pi['dirname'];
$csv_name = $pi['filename'];

// create new Excel instance
$excel = new PHPExcel();

// sheet setting
$excel->setActiveSheetIndex(0);
$sheet = $excel->getActiveSheet();
$sheet->setTitle($csv_name);
$sheet->getDefaultStyle()->getFont()->setSize( 11 );

// load CSV file into Excel
$reader = new PHPExcel_Reader_CSV();
$reader->setDelimiter($delimiter);
$reader->setEnclosure($enclosure);
$reader->setLineEnding("\n");
try{
  $reader->loadIntoExisting( $csv_file, $excel);
}catch(Exception $e){
  fputs(STDERR, "ERROR: CSV file does not open out.\n");
  exit(1);
}

// get max size of row/col
$row_max = $sheet->getHighestRow();
$col_max = PHPExcel_Cell::columnIndexFromString($sheet->getHighestColumn());

// column auto sizing
for ($col = 0; $col < $col_max; $col++) {
  $sheet->getColumnDimension( PHPExcel_Cell::stringFromColumnIndex( $col ) )->setAutoSize( true );
}

// save Excel 2007 xlsx
$writer = PHPExcel_IOFactory::createWriter($excel, 'Excel2007');
$excel_file = "{$csv_dir}/{$csv_name}.xlsx";
$writer->save($excel_file);
fputs(STDOUT, "saved {$excel_file}\nconvert successful !\n");
