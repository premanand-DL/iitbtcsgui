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
            self.noc.setFont(QtGui.QFont("Times", 10, QtGui.QFont.Bold))
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
            self.comboBox3.setEnabled(True)
            self.run_enh.setEnabled(True)
            self.sig_run_enh.setEnabled(True)
            #print(dirs[0])
            
            
            


        #with f:
            #data = f.read() 
    def enhan(self):
        self.textbox.move(10,275)
        self.textbox.resize(400,80)
        self.l8.move(10,255)
        self.wer2.hide()
        self.l9.hide()
        self.l8.setText('Running enhancement...Please wait...')
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
        
    def enhan1(self):
        pass

    def handleStdOut(self):
        data = self.process.readAllStandardOutput().data()
        self.textbox.append(data.decode('utf-8'))

    def handleStdErr(self):
        data = self.process.readAllStandardError().data()
        self.textbox.append(data.decode('utf-8')) 
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
        print(self.dirs[0])
        self.text1 = str(self.comboBox1.currentText())
        self.log1.setText('Decoding Started')
        self.log1.resize(self.log1.sizeHint())
        self.log1.show()
        filepath = self.dirs[0]+ '/'+self.text1 
        command = './decode_gui.sh '+ filepath
        self.process1.start(command)
        #process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    def decode1(self):
        self.text2 = str(self.comboBox2.currentText())
        self.log2.setText('Decoding Started')
        self.log2.resize(self.log2.sizeHint())
        self.log2.show()
        #print(self.filename)
        if self.text2 == 'Beamformit':
            #cmd = './run_beamformit.sh ' + self.dirs[0] + ' ' + 'recording'
            command = './decode_gui.sh enhan/demo1/beamform/'+ self.filename + '.wav'
            self.process2.start(command)
        if self.text2 == 'Max Array':
            command = './decode_gui.sh enhan/demo1/maxArray/'+ self.filename + '.wav'
            print(command)
            self.process2.start(command)
        if self.text2 == 'MVDR':
            command = './decode_gui.sh enhan/demo1/MVDR/'+ self.filename + '.wav'
            self.process2.start(command)
        if self.text2 == 'GDSB':
            command = './decode_gui.sh enhan/demo1/GDSB/'+ self.filename + '.wav'
            self.process2.start(command)

 
        #command = './decode_gui.sh '+ dir_files[1]
        #process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    def emit(self):
        self.l9.move(10,380)
        self.l9.setText('Enhancement done..')
        self.l9.show()
        self.l8.hide()
        self.puss_enh.show()
        self.dec_enh.show()
    def emit1(self):
        self.log1.setText('Decoding Complete')
        self.log1.resize(self.log1.sizeHint())
        command = 'python2.7 editDistance.py ' +self.dirs[0]+'/ref.txt out.txt' 
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
        process.wait()
        f = open('out.txt','r')
        lines = f.readlines()
        #print(lines[1])
        f.close()
        wer = 'WER'+'\n'+lines[1]
        self.wer1.setStyleSheet('color: rgb(34,142,17) ')
        self.wer1.setText(wer)
        self.wer1.show()
        #cmd = 'ls -l'
        #args = shlex.split(cmd)
        #proc = Popen(args, stdout=PIPE, stderr=PIPE)
        #out, err = proc.communicate() 
        #self.dialog = QtGui.QWidget()
        self.dialog = Second(self)
        #self.dialog.show()   
        self.dialog.exec_() 
        
        os.remove('out.txt')
        
    def emit2(self):
        self.log2.setText('Decoding Complete')
        self.log2.resize(self.log2.sizeHint())
        command = 'python2.7 editDistance.py ' +self.dirs[0]+'/ref.txt out.txt' 
        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE) 
        process.wait()
        f = open('out.txt','r')
        lines = f.readlines()
        #print(lines[1])
        f.close()
        wer = 'WER'+'\n'+lines[1]
        self.wer2.setStyleSheet('color: rgb(34,142,17) ')
        self.wer2.setText(wer)
        self.wer2.show()
        
        #cmd = 'ls -l'
        #args = shlex.split(cmd)
        #proc = Popen(args, stdout=PIPE, stderr=PIPE)
        #out, err = proc.communicate() 
        #self.dialog = QtGui.QWidget()
        self.dialog = Second(self)
        #self.dialog.show()   
        self.dialog.exec_()
        os.remove('out.txt')
        
         
    def __init__(self):
        super(Window,self).__init__()
	self.dirs = []
        self.dir_files =[]
        file_browse = QtGui.QPushButton( 'Browse' ,self)
        file_browse.clicked.connect(self.getfiles)
        self.filename = ''
        file_browse.move(10,30)
        file_browse.resize(340,30)
        #comboBox1 = QtGui.QComboBox(self)
        self.l1 = QLabel(self)
        self.l2 = QLabel(self)
        self.l1.setText('Choose the folder containing the Multi-channel audios')
        
        self.l1.move(10,10)
        self.l1.setStyleSheet('color: brown ')
        self.l1.setFont(QtGui.QFont("Times", 12, QtGui.QFont.Bold))
        self.l1.resize(self.l1.sizeHint())
        self.noc = QLabel(self)
        self.noc.move(10,70)
        
        #comboBox1.addItem('GCC-PHAT')
        #comboBox1.addItem('GCC-SCOT')
        #comboBox1.activated[str].connect(self.style_choice)
        self.l7 = QLabel(self)
        self.l7.setText('Select the multi-channel enhancement to be performed')
        self.l7.move(10,190)
        self.l7.setStyleSheet('color: brown ')
        self.l7.setFont(QtGui.QFont("Times", 12, QtGui.QFont.Bold))
        self.l7.resize(self.l7.sizeHint())
        self.comboBox1 = QtGui.QComboBox(self)
        self.comboBox1.move(10,90)
        self.comboBox1.resize(200,30)
        self.comboBox1.hide()
        #self.comboBox1.activated[str].connect(self.style_choice)
        self.puss = QtGui.QPushButton( 'Play' ,self)
        self.puss.clicked.connect(self.play)
        self.puss.move(220,90)
        self.puss.resize(60,30)
        self.puss.hide()
        self.dec = QtGui.QPushButton( 'Decode' ,self)
        self.dec.move(290,90)
        self.dec.resize(60,30)
        self.dec.hide()
        self.wer1 = QLabel(self)
        self.wer1.move(360,90)
        self.wer1.hide()
        self.dec.clicked.connect(self.decode)
        self.comboBox2 = QtGui.QComboBox(self)
        self.comboBox2.addItem('Beamformit')
        self.comboBox2.addItem('Max Array')
        self.comboBox2.addItem('MVDR')
        self.comboBox2.addItem('GDSB')
        self.comboBox2.setEnabled(False)
        self.sig_enh = QLabel(self)
        self.sig_enh.move(10,125)
        self.sig_enh.setStyleSheet('color: brown ')
        self.sig_enh.setFont(QtGui.QFont("Times", 12, QtGui.QFont.Bold))
        self.sig_enh.setText('Select the single-channel enhancement to be performed')
        self.comboBox3 = QtGui.QComboBox(self)
        self.comboBox3.addItem('NMF')
        self.comboBox3.addItem('WPE')
        self.comboBox3.setEnabled(False)
        #self.comboBox2.activated[str].connect(self.style_choice)
        self.text1 = ''
        self.text2= ''
        self.comboBox2.move(10,215)
        self.comboBox2.resize(320,30)
        self.comboBox3.move(10,150)
        self.comboBox3.resize(320,30)
        self.run_enh = QtGui.QPushButton( 'Run' ,self)
        self.run_enh.clicked.connect(self.enhan)
        self.run_enh.move(340,215)
        self.run_enh.resize(self.run_enh.sizeHint())
        self.sig_run_enh = QtGui.QPushButton( 'Run' ,self)
        self.sig_run_enh.clicked.connect(self.enhan1)
        self.sig_run_enh.move(340,150)
        self.sig_run_enh.resize(self.sig_run_enh.sizeHint())
        self.run_enh.setEnabled(False)
        self.sig_run_enh.setEnabled(False)
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
        self.puss_enh.move(220,375)
        self.puss_enh.resize(60,30)
        self.puss_enh.hide()
        self.dec_enh = QtGui.QPushButton( 'Decode' ,self)
        self.dec_enh.move(290,375)
        self.dec_enh.resize(60,30)
        self.dec_enh.hide()
        self.dec_enh.clicked.connect(self.decode1)
        self.quit = QtGui.QPushButton( 'Quit' ,self)
        self.quit.move(210,450)
        self.quit.resize(self.quit.sizeHint())
        self.quit.clicked.connect(self.close_application)
        self.wer2 = QLabel(self)
        self.wer2.move(360,375)
        self.wer2.hide()
        self.log1 = QLabel(self)
        self.log1.move(290,130)
        self.log1.hide()
        self.log2 = QLabel(self)
        self.log2.move(290,415)
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
        
        self.setGeometry(500,200,500,500)
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
        f = open('out.txt')
        lines = f.readlines()
        f.close()
        self.setWindowTitle('Decoded Text')
        self.edit.append(lines[0])
        self.edit.resize(self.edit.sizeHint())
        self.show()
        
dir_files = []  
dirs = []
app = QtGui.QApplication(sys.argv)   
app.setApplicationName('Window')     
GUI = Window()
sys.exit(app.exec_())

