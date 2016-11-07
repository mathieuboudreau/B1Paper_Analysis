import os
import re
import subprocess

def convert_dir_minc2_to_minc1(dirPath):
    '''Convert directory MINC1 files to MINC2
    
    --arg--
    string: directory path
    
    WARNING, WILL OVERWRITE OLD MINC2 FILES
    
    BE SURE TO MAKE A BACKUP OF YOUR FOLDER PRIOR TO CALLING THIS FUNCTION
    '''
    
    dirFiles = os.listdir(dirPath)
    
    for file in dirFiles:
        m = re.match(r'(.*).mnc$',file)
        if m:
            mincFile = m.group()
            print('Converting ' + mincFile)
            
            subprocess.call(['mincconvert', mincFile, mincFile[0:(len(mincFile)-4)] + '_minc1' + mincFile[-4:]])
            
            # Replace old minc1 file with temp minc1 file, deleting the temp minc1 file
            subprocess.call(['mv', mincFile[0:(len(mincFile)-4)] + '_minc1' + mincFile[-4:], mincFile])
