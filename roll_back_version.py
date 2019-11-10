import re
import os
import oss2
import sys

acc_key = "LTAI4Fkr8Cx3Gau7PuyXYdtA"
acc_sec  ="gtYxnlQurK8mz674MxmBRWwpiAFQXC"
auth = oss2.Auth(acc_key, acc_sec)
bucket = oss2.Bucket(auth, 'https://oss-cn-beijing.aliyuncs.com', 'finders-apk')
file_name = "finders-{version}.apk"
main_name = "finders.apk"
lastest = 'lastest'


def exist_version(version):
    return bucket.object_exists(file_name.format(version=version))

def get_version():
    if len(sys.argv) < 2:
        print("Ops! Need Version params!")
        return None
    version = sys.argv[1]
    if not re.match(r"\d*\.\d*\.\d*", version):
        print("Ops! Error version number was input!")
        return None
    if not exist_version(version):
        print("This version is not find in server!")
        return None
    return version
    
def get_data(version):
    data = bucket.get_object(file_name.format(version = version))
    return data.read()

def upload(data, version):
    print("Alter the last version!")
    bucket.put_object(main_name, data)
    bucket.put_object(lastest, version.encode("utf-8"))

def main():
    version = get_version()
    if not version:
        return
    print("\033[31m WARNNING! \033[0m")
    print(f"\033[31m Are You Sure To Roll The lastest version back {version}?(This operation can't be token back!)(Y/N)\033[0m: ", end="")
    check = input()
    if check not in ['y', 'Y']:
        print("Canceled!")
        return
    data = get_data(version)
    upload(data, version)
    print("Alter Success!")

if __name__ == "__main__":
    main()