#!/usr/bin/python2.7
import PyQt4
import sys
from PyQt4 import QtGui,QtCore
from PyQt4.QtCore import *
from PyQt4.QtGui import *
import os
import subprocess
from subprocess import Popen, PIPE
import shlex
class Window(QtGui.QWidget):

    def close_application(self):
        choice = QtGui.QMessageBox.question(self,'Close Application','Go you want to close',QtGui.QMessageBox.Yes | QtGui.QMessageBox.No)
        if choice == QtGui.QMessageBox.Yes:
            print('Exited')
            sys.exit()
        else:
            pass
    def getfiles(self):
        filter = "Wav File (*.wav)"
        dlg = QFileDialog(self,'Audio Files','~/Music/', filter)
        dlg.setFileMode(QtGui.QFileDialog.DirectoryOnly)
        dlg.setFilter("Audio files (*.wav)")
        filenames = QStringList()
        self.comboBox1.clear()
        self.dir_files=[]
        self.dirs=[]
        #self.run_enh.setEnabled(False)
        #self.comboBox2.setEnabled(False)
        if dlg.exec_():
            filenames = dlg.selectedFiles()
            #f = open(filenames[0], 'r')
            #print(filenames[0])
            #self.l2.setText(filenames[0])
            #self.l2.move(10,200)
            files_o = sorted(os.listdir(filenames[0]))
            count = 0
            self.dirs.append(str(filenames[0]))
            ind = []
            global dirs
            dirs = self.dirs
            for index in files_o:

                if index.find('Close') != -1 :
                    self.comboBox1.addItem(index)
                elif index.find('CH') == -1 :
                    continue
                else:
                    ind.append(index)
                    self.dir_files.append(os.path.join(str(filenames[0]),index))
                    self.comboBox1.addItem(index)
                    count +=1
            str_d = 'Total number of channels are ' + str(count)
            self.noc.setText(str_d)
            self.noc.setStyleSheet('color: red ')
            self.noc.setFont(QtGui.QFont("Times", 12, QtGui.QFont.Bold))
            self.noc.resize(self.noc.sizeHint())
            #if count==4:
                #print(ind[0])
            #    self.l2.setText(ind[0]); self.l3.setText(ind[1]);self.l4.setText(ind[2]);self.l5.setText(ind[3])
            #    self.l2.resize(self.l2.sizeHint())
            #    self.l3.resize(self.l3.sizeHint())
            #    self.l4.resize(self.l4.sizeHint())
            #    self.l5.resize(self.l5.sizeHint())
            #    self.l2_puss.resize(60,20)
            #    self.l3_puss.resize(60,20)
            #    self.l4_puss.resize(60,20)
            #    self.l5_puss.resize(60,20)
            #    self.l2_puss.show()
            #    self.l3_puss.show()
            #    self.l4_puss.show()
            #    self.l5_puss.show()
            #    self.l2_asr.resize(60,20)
            #    self.l3_asr.resize(60,20)
            #    self.l4_asr.resize(60,20)
            #    self.l5_asr.resize(60,20)
            #    self.l2_asr.show()
            #    self.l3_asr.show()
            #    self.l4_asr.show()
            #    self.l5_asr.show()
            self.comboBox1.show()
            self.puss.show()
            self.dec.show()
            self.comboBox2.setEnabled(True)
            self.run_enh.setEnabled(True)
            self.wer1.hide()
            self.wer2.hide()
            self.log1.hide()
            self.log2.hide()
            self.l9.hide()
            self.textbox.hide()
            self.puss_enh.hide()
            #print(dirs[0])
            
            
            


        #with f:
            #data = f.read() 
    def enhan(self):
        self.textbox.move(10,395)
        self.textbox.resize(500,110)
        self.l8.move(10,370)
        self.wer2.hide()
        self.l9.hide()
        self.l8.setText('Running enhancement...Please wait...')
        self.l8.setStyleSheet('color: red ')
        self.l8.resize(self.l8.sizeHint())
        self.txt = str(self.comboBox2.currentText())
        self.filename = self.dir_files[0].strip().split('/')[-1].strip().split('.')[0]
        
        if self.txt == 'Beamformit':
            #cmd = './run_beamformit.sh ' + dirs[0] + ' ' + 'recording'
            cmd = './run_beamformit.sh '+ self.dirs[0] + ' ' + self.filename
            self.process.start(cmd)
        if self.txt == 'Max Array':
            cmd = './max_array.sh ' + self.dirs[0] + ' ' + self.filename
            self.process.start(cmd)
        if self.txt == 'MVDR':
            cmd = './run_mvdr.sh ' + self.dirs[0] + ' ' + self.filename
            self.process.start(cmd)
        if self.txt == 'GDSB':
            cmd = './run_gdsb.sh ' + self.dirs[0] + ' ' + self.filename
            self.process.start(cmd)
        #process = Popen(command, stdout=PIPE, stderr=PIPE)
        #output, err = process.communicate()
        #self.process.start('ls')
        self.textbox.setReadOnly(True)
        self.textbox.show()
        
    def handleStdOut(self):
        data = self.process.readAllStandardOutput().data()
        self.textbox.append(data.decode('utf-8'))

    def handleStdErr(self):
        data = self.process.readAllStandardError().data()
        self.textbox.append(data.decode('utf-8')) 
    def handleStdOut1(self):
        data = self.process1.readAllStandardOutput().data()
        self.decoding1 = data.decode('utf-8') 
    def play(self):
        self.text1 = str(self.comboBox1.currentText())
        filepath = self.dirs[0]+ '/'+self.text1
        command = 'vlc ' + filepath
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        #process.wait()
        #print process.returncode
    def play1(self):
        self.text2 = str(self.comboBox2.currentText())
        if self.text2 == 'Beamformit':
            #cmd = './run_beamformit.sh ' + dirs[0] + ' ' + 'recording'
            command = 'vlc enhan/demo1/beamform/'+ self.filename + '.wav'
            process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        if self.text2 == 'Max Array':
            command = 'vlc enhan/demo1/maxArray/'+ self.filename + '.max.wav'
            process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        if self.text2 == 'MVDR':
            command = 'vlc enhan/demo1/MVDR/'+ self.filename + '.wav'
            process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        if self.text2 == 'GDSB':
            command = 'vlc enhan/demo1/GDSB/'+ self.filename + '.wav'
            process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)

        #s = dir_files[1]
        #command = 'vlc ' + s
        #process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    def decode(self):
        #print(self.dirs[0])
        self.text1 = str(self.comboBox1.currentText())
        self.log1.setText('Decoding Started')
        self.log1.resize(self.log1.sizeHint())
        self.log1.show()
        filepath = self.dirs[0]+ '/'+self.text1 
        self.command = './decode_gui.sh '+ filepath
        self.process1.start(self.command)
        #process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    def decode1(self):
        self.text2 = str(self.comboBox2.currentText())
        self.log2.setText('Decoding Started')
        self.log2.resize(self.log2.sizeHint())
        self.log2.show()
        #print(self.filename)
        if self.text2 == 'Beamformit':
            #cmd = './run_beamformit.sh ' + self.dirs[0] + ' ' + 'recording'
            self.command = './decode_gui1.sh enhan/demo1/beamform/'+ self.filename + '.wav'
            self.process2.start(self.command)
        if self.text2 == 'Max Array':
            self.command = './decode_gui1.sh enhan/demo1/maxArray/'+ self.filename + '.wav'
            #print(command)
            self.process2.start(self.command)
        if self.text2 == 'MVDR':
            self.command = './decode_gui1.sh enhan/demo1/MVDR/'+ self.filename + '.wav'
            self.process2.start(self.command)
        if self.text2 == 'GDSB':
            self.command = './decode_gui1.sh enhan/demo1/GDSB/'+ self.filename + '.wav'
            self.process2.start(self.command)

 
        #command = './decode_gui.sh '+ dir_files[1]
        #process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    def emit(self):
        self.l9.move(10,540)
        self.l9.setText('Enhancement done..')
        self.l9.setStyleSheet('color: red ')
        self.l9.setFont(QtGui.QFont("Times", 12, QtGui.QFont.Bold))
        self.l9.show()
        self.l8.hide()
        self.puss_enh.show()
        self.dec_enh.show()
    def emit1(self):
        process = Popen(self.command, stdout=PIPE, shell=True)
        out,err=process.communicate()
        out = out.strip().split(' ')[1:]
        out = ' '.join(out)
        f = open('out.txt','w')
        f.write(out)
        f.close()
        self.log1.setText('Decoding Complete')
        self.log1.resize(self.log1.sizeHint())
        command = 'python2.7 editDistance.py ' +self.dirs[0]+'/ref.txt out.txt' 
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        process.wait()
        f = open('wer.txt','r')
        lines = f.readlines()
        #print(lines[1])
        f.close()
        wer = 'Word Error Rate'+'\n'+lines[0]
        self.wer1.setStyleSheet('color: rgb(34,142,17) ')
        self.wer1.setText(wer)
        self.wer1.setFont(QtGui.QFont("Times", 13, QtGui.QFont.Bold))
        self.wer1.resize(self.wer1.sizeHint())
        self.wer1.show()
        #cmd = 'ls -l'
        #args = shlex.split(cmd)
        #proc = Popen(args, stdout=PIPE, stderr=PIPE)
        #out, err = proc.communicate() 
        #self.dialog = QtGui.QWidget()
        self.dialog = Second(self)
        #self.dialog.show()   
        self.dialog.exec_() 
        
        #os.remove('out.txt')
        
    def emit2(self):
        process = Popen(self.command, stdout=PIPE, shell=True)
        out,err=process.communicate()
        out = out.strip().split(' ')[1:]
        out = ' '.join(out)
        f = open('enh.txt','w')
        f.write(out)
        f.close()
        self.log2.setText('Decoding Complete')
        self.log2.resize(self.log2.sizeHint())
        command = 'python2.7 editDistance.py ' +self.dirs[0]+'/ref.txt enh.txt' 
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE) 
        process.wait()
        f = open('wer.txt','r')
        lines = f.readlines()
        #print(lines[1])
        f.close()
        wer = 'Word Error Rate'+'\n'+lines[0]
        self.wer2.setText(wer)
        self.wer2.setStyleSheet('color: green')
        self.wer2.setFont(QtGui.QFont("Times", 13, QtGui.QFont.Bold))
        self.wer2.resize(self.wer2.sizeHint())
        self.wer2.show()
        
        #cmd = 'ls -l'
        #args = shlex.split(cmd)
        #proc = Popen(args, stdout=PIPE, stderr=PIPE)
        #out, err = proc.communicate() 
        #self.dialog = QtGui.QWidget()
        self.dialog = Second(self)
        #self.dialog.show()   
        self.dialog.exec_()
        if os.path.exists('out.txt') : os.remove('out.txt')
        os.remove('enh.txt')
        
        
         
    def __init__(self):
        super(Window,self).__init__()
        self.command= ''
        self.dirs = []
        self.dir_files =[]
        file_browse = QtGui.QPushButton( 'Browse' ,self)
        file_browse.clicked.connect(self.getfiles)
        self.filename = ''
        file_browse.move(10,40)
        file_browse.resize(640,40)
        #comboBox1 = QtGui.QComboBox(self)
        self.l1 = QLabel(self)
        self.l2 = QLabel(self)
        self.l1.setText('Choose the folder containing the Multi-channel audios')
        
        self.l1.move(10,10)
        self.l1.setStyleSheet('color: brown ')
        self.l1.setFont(QtGui.QFont("Times", 14, QtGui.QFont.Bold))
        self.l1.resize(self.l1.sizeHint())
        self.noc = QLabel(self)
        self.noc.move(10,80)
        
        #comboBox1.addItem('GCC-PHAT')
        #comboBox1.addItem('GCC-SCOT')
        #comboBox1.activated[str].connect(self.style_choice)
        self.l7 = QLabel(self)
        self.l7.setText('Select the enhancement to be performed')
        self.l7.move(10,290)
        self.l7.setStyleSheet('color: brown ')
        self.l7.setFont(QtGui.QFont("Times", 14, QtGui.QFont.Bold))
        self.l7.resize(self.l7.sizeHint())
        self.comboBox1 = QtGui.QComboBox(self)
        self.comboBox1.move(10,110)
        self.comboBox1.resize(400,40)
        self.comboBox1.hide()
        #self.comboBox1.activated[str].connect(self.style_choice)
        self.puss = QtGui.QPushButton( 'Play' ,self)
        self.puss.clicked.connect(self.play)
        self.puss.move(420,110)
        self.puss.resize(80,40)
        self.puss.hide()
        self.dec = QtGui.QPushButton( 'Decode' ,self)
        self.dec.move(520,110)
        self.dec.resize(80,40)
        self.dec.hide()
        self.wer1 = QLabel(self)
        self.wer1.move(620,105)
        self.wer1.hide()
        self.dec.clicked.connect(self.decode)
        self.comboBox2 = QtGui.QComboBox(self)
        self.comboBox2.addItem('Beamformit')
        self.comboBox2.addItem('Max Array')
        self.comboBox2.addItem('MVDR')
        self.comboBox2.addItem('GDSB')
        self.comboBox2.setEnabled(False)
        #self.comboBox2.activated[str].connect(self.style_choice)
        self.text1 = ''
        self.text2= ''
        self.comboBox2.move(10,320)
        self.comboBox2.resize(640,40)
        self.run_enh = QtGui.QPushButton( 'Run' ,self)
        self.run_enh.clicked.connect(self.enhan)
        self.run_enh.move(670,320)
        self.run_enh.resize(80,40)
        self.run_enh.setEnabled(False)
        self.textbox = QTextEdit(self)
        self.textbox.hide() 
        self.l8 = QLabel(self)
        self.process = QtCore.QProcess(self)
        self.process.readyReadStandardOutput.connect(self.handleStdOut)
        self.process.readyReadStandardError.connect(self.handleStdErr)
        self.process.finished.connect(self.emit)
        self.process1 = QtCore.QProcess(self)
        self.process1.readyReadStandardOutput.connect(self.handleStdOut)
        self.process1.readyReadStandardError.connect(self.handleStdErr)
        self.process1.finished.connect(self.emit1) 
        self.process2 = QtCore.QProcess(self)
        self.process2.readyReadStandardOutput.connect(self.handleStdOut)
        self.process2.readyReadStandardError.connect(self.handleStdErr)
        self.process2.finished.connect(self.emit2) 
        self.l9 = QLabel(self)
        self.l9.hide()
        self.puss_enh = QtGui.QPushButton( 'Play' ,self)
        self.puss_enh.clicked.connect(self.play1)
        self.puss_enh.move(420,530)
        self.puss_enh.resize(80,40)
        self.puss_enh.hide()
        self.dec_enh = QtGui.QPushButton( 'Decode' ,self)
        self.dec_enh.move(520,530)
        self.dec_enh.resize(80,40)
        self.dec_enh.hide()
        self.dec_enh.clicked.connect(self.decode1)
        self.quit = QtGui.QPushButton( 'Quit' ,self)
        self.quit.move(360,700)
        self.quit.resize(self.quit.sizeHint())
        self.quit.clicked.connect(self.close_application)
        self.wer2 = QLabel(self)
        self.wer2.move(620,525)
        self.wer2.hide()
        self.log1 = QLabel(self)
        self.log1.move(520,160)
        self.log1.hide()
        self.log2 = QLabel(self)
        self.log2.move(510,575)
        self.log2.hide()    

        #self.dialog = Second(self)
        #horizontalLayout = QtGui.QHBoxLayout(self)
        #horizontalLayout.addWidget( comboBox1 )
        #horizontalLayout.addWidget( comboBox2 )
        #run_asr = QtGui.QPushButton( 'ASR' ,self)
        #run_asr.clicked.connect(self.getasr)
        #run_asr.move(10,390)
        #run_asr.resize(300,30)
        #run_asr.resize(run_asr.sizeHint())
        #self.asr_out = QLineEdit("Hello Python")
        #self.asr_out.resize(self.asr_out.sizeHint())
        #self.asr_out.setFixedWidth(100)
        #verticalLayout = QtGui.QVBoxLayout( self )
        #verticalLayout.addWidget( file_browse )
        #verticalLayout.addStretch(0.5)
        #verticalLayout.addLayout( horizontalLayout )
        
        #verticalLayout.addWidget( run_asr )
        #verticalLayout.addStretch(1)
        #verticalLayout.addWidget( self.asr_out )
        #self.setLayout( verticalLayout )
        
        #self.setLayout(vbox)
        #mainMenu = self.menuBar()
        #fileMenu = mainMenu.addMenu('&File')
        #fileMenu.addAction(extractAction)
        #self.editor()
        #self.home()
        
        self.setGeometry(500,200,800,800)
        self.setWindowTitle('IITB-TCS--GUI')
        self.setWindowIcon(QtGui.QIcon('tcs.png'))
        #extractAction = QtGui.QAction('Get to the chopper',self)
        #extractAction.setShortcut('Ctrl+Q')
        #extractAction.setStatusTip('Leave the app')
        #extractAction.triggered.connect(self.close_application)

        #self.statusBar()
        self.show()

class Second(QtGui.QDialog):
    def __init__(self,parent=None):
        super(Second, self).__init__(parent)
        #self.setupUi(self)
        self.edit = QtGui.QTextEdit(self)
        self.edit.setReadOnly(True)
        self.edit.setFont(QtGui.QFont("Times", 12, QtGui.QFont.Bold))
        f = open(dirs[0]+'/ref.txt','r')
        lines = f.readlines()
        redColor = QColor(255, 0, 0)
        blackColor = QColor(0, 0, 0)
        blueColor = QColor(0,0,255)
        self.edit.setTextColor(redColor)
        self.edit.append('Reference:  '+lines[0])
        f.close()
        
        if os.path.exists('out.txt'):
           f = open('out.txt','r')
           lines = f.readlines()
           self.edit.setTextColor(blackColor)
           self.edit.append('Pre-Enhan Hypothesis:  '+lines[0]+'\n')
           f.close()
        if os.path.exists('enh.txt'):
           f = open('enh.txt','r')
           lines = f.readlines()
           self.edit.setTextColor(blueColor)
           self.edit.append('Post-Enhan Hypothesis:  '+lines[0])
           f.close()
        self.setWindowTitle('Decoded Text')
        self.edit.resize(400,300)
        self.show()
        
dir_files = []  
dirs = []
app = QtGui.QApplication(sys.argv)   
app.setApplicationName('Window')     
GUI = Window()
sys.exit(app.exec_())

