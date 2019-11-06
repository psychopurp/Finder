import re
import os
import oss2

acc_key = "LTAI4Fkr8Cx3Gau7PuyXYdtA"
acc_sec  ="gtYxnlQurK8mz674MxmBRWwpiAFQXC"
auth = oss2.Auth(acc_key, acc_sec)
bucket = oss2.Bucket(auth, 'https://oss-cn-beijing.aliyuncs.com', 'finders-apk')
file_name = "finders-{version}.apk"
main_name = "finders.apk"
lastest = 'lastest'

def get_version():
    with open("pubspec.yaml", "r") as f:
        data = f.read()
        version = re.search(r"(?<=version: )\d*\.\d*\.\d*", data)
        if not version:
            return '0.0.1'
        return version.group()

def get_lastest_version():
    lastest_stream = bucket.get_object(lastest)
    return lastest_stream.read().decode("utf-8")

def exist_version(version):
    return bucket.object_exists(file_name.format(version=version))

now_version = get_version()
lastest_version = get_lastest_version()

def build():
    print("Complie the new version!")
    code = os.system("flutter build apk")
    if code:
        return None
    try:
        with open(r"build\app\outputs\apk\release\app-release.apk", "rb") as f:
            return f.read()
    except FileNotFoundException as e:
        return None

def upload(data):
    bucket.put_object(file_name.format(version=now_version), data)
    if now_version > lastest_version:
        print("Alter the last version!")
        bucket.put_object(main_name, data)
        bucket.put_object(lastest, now_version.encode("utf-8"))

def main():
    if exist_version(now_version):
        check = input(f"Version already publish!\nIf it contains important update, should change the version number.\nReplace it? Online Version({lastest_version}), Now version({now_version}): ")
        if check not in ['y', 'Y']:
            print("Canceled!")
            return
    data = build()
    if not data:
        print("Build Error!")
        return
    upload(data)
    if exist_version(now_version):
        print("OK! New version already publish!")
    else:
        print("Something wrong. Please check.")
    
if __name__ == "__main__":
    main()