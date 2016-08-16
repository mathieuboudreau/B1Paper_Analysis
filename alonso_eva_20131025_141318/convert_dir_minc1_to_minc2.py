import os
import re
import subprocess

def convert_dir_minc1_to_minc2(dirPath):
    dirFiles = os.listdir(dirPath)
    
    for file in dirFiles:
        m = re.match(r'(.*).mnc$',file)
        if m:
            mincFile = m.group()
            print(mincFile)
            subprocess.call(['mincconvert', '-2', mincFile, mincFile[0:(len(mincFile)-4)] + '_minc2' + mincFile[-4:]])
