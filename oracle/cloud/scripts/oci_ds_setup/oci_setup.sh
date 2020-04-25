export profile=$'[DEFAULT]'
export user=$'user=<oci_user_ocid>'
export keyfile=$'key_file=/home/datascience/.oci/oci_api_key.pem'
export tenancy=$'tenancy=<tenancy_ocid>'
export region=$'region=<region_name>'

cd /home/datascience/
mkdir .oci
cd .oci
openssl genrsa -out ~/.oci/oci_api_key.pem 2048
chmod go-rwx ~/.oci/oci_api_key.pem
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem

export fingerprint=$'fingerprint='$(openssl rsa -pubout -outform DER -in ~/.oci/oci_api_key.pem | openssl md5 -c)

newline=$'\n'

find="(stdin)= "
rplc=''
fngr=${fingerprint//$find/$rplc}

configStr="${profile}${newline}${user}${newline}${fngr}${newline}${keyfile}${newline}${tenancy}${newline}${region}"
echo "${configStr}"


FILE=$"config"

if [ -f "$FILE" ];
then
   rm $FILE
fi

echo "${configStr}" >> config

cat oci_api_key_public.pem
