import os
import re
import subprocess

def convert_dir_minc1_to_minc2(dirPath):
    '''Convert directory MINC1 files to MINC2
    
    --arg--
    string: directory path
    
    WARNING, WILL OVERWRITE OLD MINC1 FILES
    
    BE SURE TO MAKE A BACKUP OF YOUR FOLDER PRIOR TO CALLING THIS FUNCTION
    '''
    
    dirFiles = os.listdir(dirPath)
    
    for file in dirFiles:
        m = re.match(r'(.*).mnc$',file)
        if m:
            mincFile = m.group()
            print('Converting ' + mincFile)
            
            subprocess.call(['mincconvert', '-2', mincFile, mincFile[0:(len(mincFile)-4)] + '_minc2' + mincFile[-4:]])
            
            # Replace old minc1 file with temp minc2 file, deleting the temp minc2 file
            subprocess.call(['mv', mincFile[0:(len(mincFile)-4)] + '_minc2' + mincFile[-4:], mincFile])
