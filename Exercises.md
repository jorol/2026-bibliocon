# Exercises

Login per SSH and download files for the exercises:

```bash
# ssh connection
$ ssh <user>@<ipaddress>
# download files
$ wget https://jorol.github.io/2026-bibliocon/files/processing-marc.zip
# unzip files
$ unzip processing-marc.zip
# move to directory
$ cd processing-marc
# list directories and files
$ ls -1 .
```

## MARC 21 documentation

Check the [MARC 21 documenation](https://www.loc.gov/marc/bibliographic/) of the some fields:

* 007 Physical Description Fixed Field
* 020 International Standard Book Number
* 100 Main Entry - Personal Name 
* 245 Title Statement 
* 700 Added Entry - Personal Name 

Are data elements positionally defined? Are codes used within fields? Are fields or subfields repeatable?

## MARC 21 serializations

Look at the different MARC serialization of the "Code4lib" record (`code4lib.*`), e.g.:

```bash
# on the command-line
# press `q` to quit command
$ less code4lib.mrc
$ less code4lib.mrk
$ less code4lib.xml
$ less code4lib.seq
```

## Download MARC data


... from a Z39.50 server with `yaz-client` and a command file

See ["Bath Profile"](http://www.ukoln.ac.uk/interop-focus/activities/z3950/int_profile/bath/draft/stable1.html#5.A.1.%20Functional%20Area%20A:%20Level%201%20Basic%20Bibliographic%20Search%20and%20Retrieval%20Emphasizing%20Precision) or ["Bib-1 Attribute Set"](https://software.indexdata.com/yaz/doc/bib1.html) for common search and retrieval operations and attribute sets.

```bash
# show command file
$ cat z3950.cmdfile
open lx2.loc.gov/LCDB
format 1.2.840.10003.5.10
element F
set_marcdump z3950_loc.mrc
find @attr 5=100 @attr 1=21 "Perl"
show 1+50
exit
# run command file
$ yaz-client -f z3950.cmdfile
# show records
$ cat -v z3950_loc.mrc
```

You can edit the command file, e.g. the query:

```bash
$ micro z3950.cmdfile 
# press `CTRL + s` to save file and `CTRL + x` to quit editor
```

### ... from a SRU server with `catmandu`

See [SRU explain](https://sru.kobv.de/k2?operation=explain&version=1.1) for supported indices and formats and [Catmandu::SRU](https://metacpan.org/pod/Catmandu::SRU)
 for client options.

```bash
$ catmandu convert SRU \
--base https://sru.kobv.de/k2 \
--recordSchema MARCXML \
--query 'dc.creator = "Tempest, Kae"' \
--parser marcxml \
to MARC --type XML > sru_kobv.xml
# reformat and reindent MARC 21 XML file
$ xmllint --format sru_kobv.xml
```

## Validate your data

### ... with `yaz-marcdump`

```bash
# validate MARC 21 ISO format
$ yaz-marcdump -n loc.mrc
# validate MARC 21 XML format
$ yaz-marcdump -n -i marcxml sru_kobv.xml
# validate MARC 21 ISO file with errors 
$ yaz-marcdump -n pride-and-prejudice-with-many-errors.mrc
```

### ... with `xmllint`

```bash
# just validate file, no other ouptput
$ xmllint --noout --schema MARC21slim.xsd loc.mrc.xml
$ xmllint --noout --schema MARC21slim.xsd sru_kobv.xml

```

### ... with `marcvalidate`

```bash
# validate MARC 21 ISO format
$ marcvalidate loc.mrc
# validate MARC 21 XML format
$ marcvalidate --type XML loc.mrc.xml
```

## Create statistics for your data

### ... with `marcstats.pl`

```bash
# generate statistics for MARC 21 ISO format
$ marcstats.pl loc.mrc
# marcstats.pl can handle only MARC (ISO 2709) files
# use a command line substitution to generate that format
$ marcstats.pl <(catmandu convert MARC --type XML to MARC < loc.mrc.xml)
# replace spaces with dots & save result in file
$ marcstats.pl --dots -o stats_loc.txt loc.mrc
# show statistic
$ less stats_loc.txt
# press `q` to quit
```

### ... with `catmandu`

```bash
# "break" MARC record in pieces
$ catmandu convert MARC --type XML to Breaker --handler marc \
< loc.mrc.xml > loc.breaker
# generate statistic
$ catmandu breaker loc.breaker
# save statistic as tab-separated TSV file
$ catmandu breaker --as TSV loc.breaker > loc.tsv
$ less loc.tsv
# press `q` to quit
```

## Unicode normalization

```bash
# convert NFD to NFC normalization form  
$ uconv -x NFC nfd.xml > nfc.xml
# show difference between files: only lines with umlauts are marked. 
$ diff nfc.xml nfd.xml
# show the different Unicode code points for NFC and NFD normalized umlauts
$ echo -n 'üü' | uconv -x Any-Name
$ echo -n 'ää' | uconv -x Any-Name
```

## Transform different MARC serializations

### ... with `yaz-marcdump`

```bash
# MARC (ISO 2709) to MARC Line
$ yaz-marcdump -o line loc.mrc
# MARC XML to Turbomarc
$ yaz-marcdump -i marcxml -o turbomarc loc.mrc.xml
```

### ... with `catmandu`

```bash
# MARC (ISO 2709) to MARC-in-JSON
$ catmandu convert MARC to MARC --type MiJ < elag.z3950.mrc
# MARC XML to MARCMaker
$ catmandu convert MARC --type XML to MARC --type MARCMaker < loc.mrc.xml
# MARC to Breaker
$ catmandu convert MARC --type XML to Breaker --handler marc < loc.mrc.xml 
# MARC to CSV. mapping with fixes required.
$ catmandu convert MARC --type XML to TSV \
--fix 'marc_map(022a,bibo_issn,join:";");marc_map(245abc,dc_title,join:" ");remove_field(record)' \
< loc.mrc.xml
```

### ... with `xlstproc`

```bash
# MARC XML to MODS
$ xsltproc MARC21slim2MODS3-7.xsl loc.mrc.xml
# MARC XML to RFD-DC
$ xsltproc MARC21slim2RDFDC.xsl loc.mrc.xml
# MARC XML to BIBFRAME
$ xsltproc bibframe-xsl/marc2bibframe2.xsl loc.mrc.xml
```

## Extract data from MARC records

### ... with `xmllint`

Get a list of all MARC tags:

```bash
$ xmllint --xpath '//@tag' loc.mrc.xml | sort | uniq -c
```

Get all IDs from MARC 001:

```bash
$ xmllint --xpath '//*[local-name()="controlfield"][@tag="001"]/text()' loc.mrc.xml
```

Get all MARC 245 subfields:

```bash
$ xmllint --xpath '//*[local-name()="datafield"][@tag="245"]' loc.mrc.xml
```

Get title from MARC 245$a:

```bash
$ xmllint --xpath '//*[local-name()="datafield"][@tag="245"]/*[local-name()="subfield"][@code="a"]/text()' loc.mrc.xml
```

Get all ISSN from MARC 022$a:

```bash
$ xmllint --xpath '//*[local-name()="datafield"][@tag="022"]/*[local-name()="subfield"][@code="a"]/text()' loc.mrc.xml
```

Extract all DDC numbers from MARC 082$a:

```bash
$ xmllint --xpath '//*[local-name()="datafield"][@tag="082"]/*[local-name()="subfield"][@code="a"]/text()' loc.mrc.xml
```

### ... with `catmandu` and command-line utilities

Use `Catmandu::Breaker` in combination unix utilities like `grep`, `cut`, `sort` and `uniq`:

```bash
# check the Breaker output format
$ catmandu convert MARC --type XML to Breaker --handler marc < loc.mrc.xml
# get all ISSNs from MARC 022$a
$ catmandu convert MARC --type XML to Breaker --handler marc < loc.mrc.xml | \
grep -P '\t022a\t' | cut -f 3 | sort
# get all uniq DDC form MARC 082$a
$ catmandu convert MARC --type XML to Breaker --handler marc < loc.mrc.xml | \
grep -P '\t082a\t' | cut -f 3 | sort | uniq -c 
```

Use the `MARCMaker` format in combination with `grep`:

```bash
# get all MARC 022 fields
$ catmandu convert MARC --type XML to MARC --type MARCMaker < loc.mrc.xml | \
grep -P '^=022'
# get all MARC 245 fields with indicators 0  
$ catmandu convert MARC --type XML to MARC --type MARCMaker  < loc.mrc.xml | \
grep -P '^=245  00'
```

Use fix `marc_map` to extract and map data from MARC records:

```bash
$ catmandu convert MARC --type XML to TSV \
--fix 'marc_map(001,dc_identifier);marc_map(020a,bibo_isbn,join:",");marc_map(022a,bibo_issn,join:",");marc_map(245a,dc_title);remove_field(record)' \
--fields dc_identifier,bibo_isbn,bibo_issn,dc_title \
< loc.mrc.xml
```

Extract the language code from MARC 008 and lookup the language:

```bash
$ catmandu convert MARC --type XML to TSV \
--fix 'marc_map(008/35-37,dc_language);lookup(dc_language,dict_languages.csv,delete:1);remove_field(record)' \
< loc.mrc.xml
```

Extract fields with specific indicators:

```bash
$ catmandu convert MARC --type XML to TSV \
--fix 'marc_map("246[1,4]",marc_varyingFormOfTitle);remove_field(record)' \
--fields _id,marc_varyingFormOfTitle \
< loc.mrc.xml
```

Extract several subfields with certain codes:

```bash
# as string
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(245abc,dc_title,join:" ");remove_field(record)' \
< loc.mrc.xml
# as array
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(245abc,dc_title,split:1);remove_field(record)' \
< loc.mrc.xml
# as array in certain order
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(245cba,dc_title,split:1,pluck:1);remove_field(record)' \
< loc.mrc.xml
```

Extract data from repeatable fields:

```bash
# create an array for subjects
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(650a,dc_subject,split:1);remove_field(record)' \
< loc.mrc.xml
```

Extract data from repeatable fields with repeatable subfields:

```bash
# create one array for index terms
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(655ay,marc_indexTermGenre,split:1);remove_field(record)' \
< loc.mrc.xml
# create an array of arrays for index terms, one array for each MARC field.
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(655ay,marc_indexTermGenre,split:1,nested_arrays:1);remove_field(record)' \
< loc.mrc.xml
```

Extract subfields depending on another subfield value:

```bash
$ catmandu convert MARC --type XML to JSON --pretty 1 \
--fix '
do marc_each()
  if marc_match(856x,EZB)
    marc_map(856u,ezb_uri)
  end
end;
remove_field(record)' \
< code4lib.xml
```

Assign a new value to (sub)fields:

```bash
$ catmandu convert MARC --type XML to MARC --type MARCMaker \
--fix 'marc_set(001,123456789);marc_set(245a,"My Title");marc_set(245b," ... added by fix.")' \
< loc.mrc.xml
```

Remove (sub)fields from records:

```bash
$ catmandu convert MARC --type XML to MARC --type MARCMaker \
--fix 'marc_remove(003);marc_remove(6..);marc_remove(856xz);' \
< loc.mrc.xml
```

Add a new MARC 999 field to all records:

Create a UUID with fix `uuid` and add it as subfield $b to the new MARC field. 

```bash
$ catmandu convert MARC --type XML to MARC --type MARCMaker \
--fix 'uuid(uuid);marc_add(999,a,"Local UUID",b,$.uuid)' \
< loc.mrc.xml
```

Replace strings in (sub)fields:

```bash
$ catmandu convert MARC --type XML to MARC --type MARCMaker \
--fix 'marc_replace_all(856u,"^http://","https://")' \
< loc.mrc.xml
```

Filter MARC records:

```bash
$ catmandu convert -v MARC --type XML to MARC --type MARCMaker \
< loc.mrc.xml
$ catmandu convert -v MARC --type XML to MARC --type MARCMaker \
--fix 'select marc_match(245a,Perl)' \
< loc.mrc.xml
```

Validate MARC records:

```bash
# catch errors
$ catmandu convert -v MARC --type XML to JSON --pretty 1 \
--fix 'validate(.,MARC,error_field: errors);remove_field(record)' \
< loc.mrc.xml
# filter valid records
$ catmandu convert -v MARC --type XML to MARC --type MARCMaker \
--fix 'select valid(.,MARC)' \
< loc.mrc.xml
```

Extract and normalize IBSNs, keep only uniques:

```bash
$ catmandu convert -v MARC --type XML to JSON --pretty 1 \
--fix 'marc_map(020a,bibo_isbn,split:1); replace_all(bibo_isbn.*,"\s.*$","");isbn13(bibo_isbn.*);uniq(bibo_isbn);remove_field(record);' \
< loc.mrc.xml
```

## Documentation of software tools

Check the documentation of the recommended tools:

```bash
$ catmandu --help
$ catmandu info
$ marcvalidate --help
$ marcstats.pl --help
# press `q` to quit `man` pages
$ man uconv
$ man yaz-client
$ man yaz-marcdump
$ man xmllint
$ man xsltproc
```