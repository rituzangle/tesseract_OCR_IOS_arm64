export TESSDATA_PREFIX=./tessdata # path to traineddata file
# my traineddata file (best version is needed for tesseract 5), is in the tessdata folder in the current directory.
# Adjust the path as needed.
#  ls -lh tessdata/
#-rw-r--r--@ 1 me  staff    11M Feb  8 23:51 pan.traineddata

# I saved scan of a page of Panjabi text as `Scans/Panjabi_text_test1.png`.
# Adjust the path and filename as needed.
echo "Root/bin/tesseract was created by building tesseract from source using the build scripts in the Root/bin directory. It is a custom build of tesseract 5.5.2 with support for Panjabi (Punjabi) language, Gurmukhi script."

# Run this command from your project's root directory, after exporting the TESSDATA_PREFIX environment variable to point to the directory containing the `pan.traineddata` file. This command will process the scanned image and output the recognized text to `ocr_output.txt`.:
Root/macos_arm64/bin/tesseract Panjabi_text_test1.jpg ocr_outout -l pan
echo "ocr result: less ocr_output.txt"

echo " Result sample: "
cat ocr_output.txt

# ਇਕ ਰੋਈ ਸੀ ਧੀ ਪੰਜਾਬ ਦੀ
# 1947 ਵਿੱਚ ਦੇਸ਼ ਦੀ ਵੇਡ ਸਮੇਂ ਦੀਆਂ ਕੁਝ ਅਜਿਹੀਆਂ ਘਟਨਾਵਾਂ ਹਨ ਜੋ

# ਬਚਪਨ ਤੋਂ ਲੈ ਕੇ ਅੱਜ ਤੱਕ ਮੈਨੂੰ ਕਦੇ ਭੁੱਲੀਆਂ ਨਹੀਂ, ਸਗੋਂ ਜੇ ਇਜ ਕਹਿ ਲਈਏ ਤਾਂ
# ਠੀਕ ਹੋਵੇਗਾ ਕਿ ਉਨ੍ਹਾਂ ਯਾਦਾਸ਼ਤਾਂ ਨੇ ਮੇਰਾ ਸਾਥ ਕਦੇ ਨਹੀਂ ਛੱਡਿਆ ।

# 1947 ਅਗਸਤ ਦੇ ਅਖੀਰਲੇ ਦਿਨਾਂ ਦੀ ਅਜਿਹੀ ਹੀ ਇਕ ਘਟਨਾ ਹੈ ਜੋ ਮੈਨ
# -ਭੁੱਲੀ ਨਹੀਂ । ਉਸ ਦਿਨ ਸਵੇਰੇ-ਸਵੇਰੇ ਹੀ ਤਾੜ੍ਹ-ਤਾੜ੍ਹ ਗੋਲੀਆਂ ਚੱਲਣ ਦੀ ਆਵਾਜ਼ ਨੇ
# ਸਾਡਾ ਸਾਰਾ ਪਿੰਡ ਚੌਕਾ ਦਿੱਤਾ ਸੀ । ਲੋਕ ਤਾਂ ਐਦਰੋਂ-ਐਦਰੀ ਪਹਿਲਾਂ ਹੀ ਬਹੁਤ ਡਰੇ ਹੋਏ
# ਸਨ । ਕਈਆਂ ਨੂੰ ਤਾਂ ਇਹ ਡਰ ਸੀ ਕਿ ਕਿਤੇ ਮੁਸਲਮਾਨਾਂ ਨੂੰ ਮਾਰਨ ਆਏ ਦੂਜੇ ਪਿੰਡਾਂ
# ਦੇ ਧਾੜਵੀ ਉਨ੍ਹਾਂ ਨੂੰ ਹੀ ਭੁਲੇਖੇ ਨਾਲ ਨਾ ਮਾਰ ਜਾਣ ਤੇ ਕਈਆਂ ਨੂੰ ਵਿਚੋਂ ਇਹ ਡਰ ਵੀ
# ਸੀਕਿ ਸਾਡੇ ਨੇੜੇ ਦੇ ਮੁਸਲਮਾਨਾਂ ਦੇ ਦੋ ਵੱਡੇ ਪਿੰਡਾਂ ਆਂਡਲੂ ਤੇ ਹਲਵਾਰੇ ਤੋਂ ਮੁਸਲਮਾਨ
# ਇੱਕਠੇ ਹੋ ਕੇ ਨਾ ਆ ਜਾਣ ਤੇ ਸਿੱਖ ਤੇ ਹਿੰਦੂਆਂ ਨੂੰ ਨਾ ਮਾਰ ਜਾਣ । ਜਦੋਂ ਇਹ ਪਤਾ
# ਲੱਗਿਆ ਕਿ ਗੋਲੀ ਸਾਡੇ ਪਿਛਵਾੜੇ ਦੇ ਮੁਸਲਮਾਨਾਂ ਦੇ ਮੁਹੱਲੇ ਵਿਚ ਹੀ ਚੱਲ ਰਹੇ ਸੀ ਤਾਂ
# ਡਰ ਕੁਝ ਘਟਿਆ । ਗੋਲੀ ਚਲਾਉਣ ਵਾਲਿਆਂ ਨੇ ਮਿਟਾਂ-ਸਕਿੰਟਾਂ ਵਿਚ ਘਰਾਂ ਨੂੰ ਅੱਗਾਂ
# ਲਾ ਦਿੱਤੀਆਂ ਤੇ ਕੋਈ ਦੋ ਦਰਜਨ ਦੇ ਕਰੀਬ ਮੁਸਲਮਾਨਾਂ ਨੂੰ ਵੀ ਮਾਰ ਦਿੱਤਾ । ਮੁਸਲਮਾਨ
# ਮਰਦ, ਔਰਤਾਂ, ਬੱਚੇ, ਬੁੱਢੇ ਸਭ ਜਾਨਾਂ ਬਚਾਉਣ ਲਈ ਘਰਾਂ ਵਿਚੋਂ ਨਿਕਲ ਕੇ ਜਿੱਧਰ ਹੂ
# ਕਮਤਾਂ ਦੇ ਜਵਾਨਾਂ ਨੇ ਗੋਲੀ ਚਲਾਈ ਸੀ ਉੱਥੇ ਹੀ ਭੱਜ ਕੇ ਜਾ ਰਹੇ ਸੀ ।
# ... excerpt from ocr_output.txt
