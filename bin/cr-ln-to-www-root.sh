#!/bin/bash
#
#3> <> prov:wasGeneratedBy [ prov:qualifiedAssociation [ prov:hadPlan <https://raw.github.com/timrdf/csv2rdf4lod-automation/master/bin/aggregate-source-rdf.sh> ] ] .
#3> <https://raw.github.com/timrdf/csv2rdf4lod-automation/master/bin/aggregate-source-rdf.sh> a prov:Plan; foaf:homepage <https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/aggregate-source-rdf.sh> .

see="https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set"
CSV2RDF4LOD_HOME=${CSV2RDF4LOD_HOME:?"not set; source csv2rdf4lod/source-me.sh or see $see"}

export PATH=$PATH`$CSV2RDF4LOD_HOME/bin/util/cr-situate-paths.sh`
export CLASSPATH=$CLASSPATH`$CSV2RDF4LOD_HOME/bin/util/cr-situate-classpaths.sh`

# cr:data-root cr:source cr:directory-of-datasets cr:dataset cr:directory-of-versions cr:conversion-cockpit
ACCEPTABLE_PWDs="cr:conversion-cockpit"
if [ `${CSV2RDF4LOD_HOME}/bin/util/is-pwd-a.sh $ACCEPTABLE_PWDs` != "yes" ]; then
   ${CSV2RDF4LOD_HOME}/bin/util/pwd-not-a.sh $ACCEPTABLE_PWDs
   exit 1
fi

if [[ "$1" == "--help" || $# -lt 1 ]]; then
   echo
   echo "usage: `basename $0` [--url-of-filepath] <file>+"
   echo
   echo "   --url-of-filepath : print the http URL of where <file> will be published."
   exit
fi

CSV2RDF4LOD_PUBLISH_VARWWW_ROOT=${CSV2RDF4LOD_PUBLISH_VARWWW_ROOT:?"not set; source csv2rdf4lod/source-me.sh "}

uri_of_path='no'
if [ "$1" == "--url-of-filepath" ]; then
   uri_of_path='yes'
   shift
fi

symbolic=""
pwd=""
if [[ "$1" == "-s" || "$CSV2RDF4LOD_PUBLISH_VARWWW_LINK_TYPE" == "soft" ]]; then
  symbolic="-sf "
  pwd=`pwd`/
  shift
fi

sudo="sudo"
if [[ `whoami` == root ]]; then
   sudo=""
elif [[ "`stat --format=%U "$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT/source"`" == `whoami` ]]; then
   sudo=""
fi

function lnwww {
   publish=""
   if [ "$2" == 'publish' ]; then
      publish="conversion"
   fi
   sourceID=`cr-source-id.sh`
   datasetID=`cr-dataset-id.sh`
   versionID=`cr-version-id.sh`

   wwwfile="$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT/source/$sourceID/file/$datasetID/version/$versionID/$publish${1#publish}"
   if [ -e "$1" -o "$2" == 'publish' ]; then
      if [ -e "$wwwfile" ]; then
         $sudo rm -f "$wwwfile"
      else
         $sudo mkdir -p `dirname "$wwwfile"`
      fi
      echo "  $wwwfile"
      $sudo ln $symbolic "${pwd}$1" "$wwwfile"
   else
      echo "  -- $1 omitted --"
   fi
}

while [ $# -gt 0 ]; do
   file="$1"
   shift
   # publish/sitemap.xml
   if [ -e "$file" ]; then
      if [ "$uri_of_path" == "yes" ]; then
         echo ${CSV2RDF4LOD_BASE_URI_OVERRIDE:-$CSV2RDF4LOD_BASE_URI}${file#$CSV2RDF4LOD_PUBLISH_VARWWW_ROOT}
      else
         directory=`dirname $file`
         if [[ "$directory" == 'source'    || "$directory" == "manual" || \
               "$directory" == 'automatic' || "$directory" == "publish" ]]; then
            lnwww $file $directory
         else  
            echo "ignoring $file"
         fi
      fi
   else
      "WARNING: $file does not exist"
   fi
done
