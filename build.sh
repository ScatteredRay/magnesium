PROJNAME=idtor.xcodeproj
TARGET=Idtor
CONFIGNAME=Release
SDKNAME=iphoneos4.3
PROVISIONPROF=IdtorVenus.mobileprovision
SCPDEST="indy@arelius.com:~/arelius.com/Idtor"
MANIFEST=manifest.plist
INSTALLHTML=Install.html

#Still don't know how to choose the provisioning profile.

#xcodebuild -list #lists build targets configs
#xcodebuild -showsdks #lists installed sdks

xcodebuild -project $PROJNAME -target $TARGET -configuration $CONFIGNAME -sdk $SDKNAME

# Find a better way to generate these!
BUILDPATH=build/$CONFIGNAME-iphoneos
APPPATH=$BUILDPATH/$TARGET.app
IPAPATH=$(echo $APPPATH | sed 's/.app/.ipa/')
PAYLOAD=$BUILDPATH/Payload

mkdir $PAYLOAD
cp -R $APPPATH $PAYLOAD
#cp  logo_itunes.png $BUILDPATH/iTunesArtwork

rm $IPAPATH

PREVPATH=$(pwd)
cd $BUILDPATH
zip -r $TARGET.ipa Payload
#zip -r $TARGET.ipa payload iTunesArtwork
cd $PREVPATH

scp $PROVISIONPROF $SCPDEST
scp $IPAPATH $SCPDEST # application/octet-stream
scp $MANIFEST $SCPDEST # test/xml
scp $INSTALLHTML $SCPDEST
# replace me
scp Icon.png $SCPDEST