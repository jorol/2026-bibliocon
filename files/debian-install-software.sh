#!/usr/bin/env bash

set -o errexit
set -o pipefail

echo  -e '\n### install dependencies ###\n'

sudo apt install -y build-essential
sudo apt install -y curl
sudo apt install -y libexpat1-dev
sudo apt install -y libgdbm-dev
sudo apt install -y libicu-dev
sudo apt install -y libssl-dev
sudo apt install -y libwrap0-dev
sudo apt install -y libxml2-dev
sudo apt install -y libxml2-utils
sudo apt install -y libxslt1-dev
sudo apt install -y libyaz-dev
sudo apt install -y pkg-config 
sudo apt install -y perl-doc
sudo apt install -y cpanminus
sudo apt install -y wget
sudo apt install -y xsltproc
sudo apt install -y yaz-dev
sudo apt install -y zlib1g
sudo apt install -y zlib1g-dev

echo -e '\n### install local Perl environment ###\n'

# install perlbrew
curl -L https://install.perlbrew.pl | bash
# edit .bashrc
echo -e '\nsource ~/perl5/perlbrew/etc/bashrc\n' >> ~/.bashrc
source ~/perl5/perlbrew/etc/bashrc
# initialize
perlbrew init
# install a Perl version
perlbrew install -j 2 -n perl-5.34.1
# switch to an installation and set it as default
perlbrew switch perl-5.34.1
# install cpanm
perlbrew install-cpanm

echo -e '\n### install Perl modules ###\n'

# need to force install because of test error
cpanm -f MARC::File::XML
# install library specific modules
cpanm MARC::Record::Stats MARC::Schema Net::Z3950::ZOOM PICA::Data
# install Catmandu modules
cpanm Catmandu Catmandu::AlephX Catmandu::BibTeX Catmandu::Breaker Catmandu::Cmd::repl Catmandu::Exporter::Table Catmandu::Exporter::Template Catmandu::Fix::cmd Catmandu::Fix::Date Catmandu::Fix::XML Catmandu::Identifier Catmandu::Importer::MODS Catmandu::LIDO Catmandu::MAB2 Catmandu::MARC Catmandu::MODS Catmandu::OAI Catmandu::OCLC Catmandu::PICA Catmandu::PNX Catmandu::RDF Catmandu::SRU Catmandu::Stat Catmandu::Template Catmandu::Validator::JSONSchema Catmandu::Wikidata Catmandu::XLS Catmandu::XML Catmandu::XSD Catmandu::Z3950

# copy MARC XML XSD to system path
wget  https://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd -P /var/local/

echo "Done ..."