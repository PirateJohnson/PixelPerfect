using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;
using FTD2XX_NET;
using Microsoft.Win32;
using Color = System.Drawing.Color;

namespace SSLAR2_Viewer
{
    /// <summary>
    /// Main display window for SSLAR2 Viewer
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private bool _loadcomplete;

        private FrmDevice _deviceForm;
        private SpinnerController _spinnerController;

        private bool _flagExit;

        private const string LabelFormatA = "##0.##";
        private const string LabelFormatB = "0.##E-00";//"00.00";

        private const int FrameWidth = 200;
        private const int FrameHeight = 150;
        private const int MaxFrameNum = 49;

        private readonly int[] _adcSData = new int[FrameHeight];
        private readonly byte[,] _rawData = new byte[FrameHeight,FrameWidth];
        private readonly double[,] _imageAfArray = new double[FrameHeight,FrameWidth];
        private readonly int[,,] _imageFArray = new int[MaxFrameNum,FrameHeight,FrameWidth];
        private readonly int[,] _itempArray = new int[FrameHeight,FrameWidth];
        private readonly byte[,] _tempArray = new byte[FrameHeight,FrameWidth];

        private double _fullNframeAvrg, _flickerNoise;
        private double _ftotalNoise, _ftotalNoise1, _ftotalNoise2, _ftempNoise, _ftotalFpn;
        private double _rtotalNoise, _rtempNoise, _rtotalFpn;
        private double _ctotalNoise, _ctempNoise, _ctotalFpn;
        private double _ptotalNoise, _ptempNoise, _ptotalFpn;
        private double _fullframeAvrg1, _fullframeAvrg2;
        private double _gainsett;

        private int _xstr, _ystr, _dx, _dy;
        private readonly Color[,] _imageData = new Color[FrameHeight*2,FrameWidth*2];
        private readonly byte[,] _bmPx2Data = new byte[FrameHeight*2,FrameWidth*2];
        private readonly byte[] _gammaTable = new byte[256];
        private readonly byte[] _defectArrayX = new byte[30000];
        private readonly byte[] _defectArrayY = new byte[30000];
        private readonly byte[] _aGammaTable = new byte[1024];
        private double _gamma;

        private readonly byte[,,] _sImageArray = new byte[12,FrameHeight,FrameWidth];
        private readonly int[,,] _siImageArray = new int[12,FrameHeight,FrameWidth];
        private readonly int[,,] _sitempArray = new int[12,FrameHeight,FrameWidth];
        private readonly byte[,,] _stempArray = new byte[12,FrameHeight,FrameWidth];
        private readonly int[,] _sadcSData = new int[12,FrameHeight];
        private readonly int[,,] _sDistTableR = new int[12,FrameHeight,1024];
        private readonly byte[,,] _sbmpData = new byte[12,FrameHeight*2,FrameWidth*2];

        private bool _portOpen;
        private FTDI _ftHandle;
        private readonly byte[] _ftInBuffer = new byte[0x10000];
        private UInt32 _ftQBytes;
        private string _sslardatafilename = "";

        private bool _videoActive;
        private bool _adcTestActive;
        private int _event2;
        private double _xbi;
        private bool _useDefectData;

        private SpinnerData _stepSpinner;
        private SpinnerData _vlnSpinner;
        private SpinnerData _ampbiasSpinner;
        private SpinnerData _compbiasSpinner;
        private SpinnerData _thresholdSpinner;
        private SpinnerData _magbiasSpinner;
        private SpinnerData _irefoutSpinner;
        private SpinnerData _eventbiasSpinner;

        private BackgroundWorker _bw;

        /// <summary>
        /// Called when the window is loaded
        /// </summary>
        /// <param name="sender">Object that called this event</param>
        /// <param name="e">Event arguments</param>
        private void WindowLoaded(object sender, RoutedEventArgs e)
        {
            _bw = new BackgroundWorker();
            _bw.DoWork += BwDoWork;
            _bw.RunWorkerCompleted += BwRunWorkerCompleted;
            _loadcomplete = true;
            SbGammaChange(sender);
            _videoActive = false;
            _adcTestActive = false;
            _useDefectData = false;
            _spinnerController = new SpinnerController();
            _stepSpinner = _spinnerController.AddSpinner(step_updown);
            _vlnSpinner = _spinnerController.AddSpinner(vln_updown);
            _ampbiasSpinner = _spinnerController.AddSpinner(ampbias_updown);
            _compbiasSpinner = _spinnerController.AddSpinner(compbias_updown);
            _thresholdSpinner = _spinnerController.AddSpinner(threshold_updown);
            _magbiasSpinner = _spinnerController.AddSpinner(magbias_updown);
            _irefoutSpinner = _spinnerController.AddSpinner(irefout_updown);
            _eventbiasSpinner = _spinnerController.AddSpinner(eventbias_updown);
            _portOpen = true;
            _portOpen = false;
            LoadDEF();
        }

        /// <summary>
        /// Called to report an error in FTDI communication
        /// </summary>
        /// <param name="errStr">Error Message</param>
        /// <param name="portStatus">Type of error</param>
        public void FtErrorReport(string errStr, FTDI.FT_STATUS portStatus)
        {
            string str = "";
            if (portStatus == FTDI.FT_STATUS.FT_OK)
                return;
            switch (portStatus)
            {
                case FTDI.FT_STATUS.FT_INVALID_HANDLE:
                    str = errStr + " - Invalid Handle...";
                    break;
                case FTDI.FT_STATUS.FT_DEVICE_NOT_FOUND:
                    str = errStr + " - Device Not Found....";
                    break;
                case FTDI.FT_STATUS.FT_DEVICE_NOT_OPENED:
                    str = errStr + " - Device Not Opened...";
                    break;
                case FTDI.FT_STATUS.FT_IO_ERROR:
                    str = errStr + " - General IO Error...";
                    break;
                case FTDI.FT_STATUS.FT_INSUFFICIENT_RESOURCES:
                    str = errStr + " - Insufficient Resources";
                    break;
                case FTDI.FT_STATUS.FT_INVALID_PARAMETER:
                    str = errStr + " - Invalid Parameter ...";
                    break;
            }
            MessageBox.Show(str, "Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }

        /// <summary>
        /// Call to exit the program on button or menu press.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ExitPrgw(object sender, RoutedEventArgs e)
        {
            _flagExit = true;
            if (_bw.IsBusy || _videoActive)
                _videoActive = false;
            else
                Close();
        }

        /// <summary>
        /// Called when runPrg stops as a result of the async process being cancelled.
        /// If async process was cancelled by a CLOSE command, it will close the window.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BwRunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            bn_Run.IsEnabled = true;
            bn_Stop.IsEnabled = false;
            RunMenu.IsEnabled = true;
            StopMenu.IsEnabled = false;

            if (_flagExit)
                Close();
        }

        /// <summary>
        /// Called to exit the program when the window CLOSE button is pressed.
        /// If the async process running the analysis is still running, it will be told to stop.
        /// When it stops, the program will exit.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ExitPrg(object sender, CancelEventArgs e)
        {
            _flagExit = true;
            _videoActive = false;
            if (_bw.IsBusy)
                e.Cancel = true;
        }

        /// <summary>
        /// Called to stop the async process on next loop.
        /// </summary>
        private void StopPrg()
        {
            _videoActive = false;
        }

        /// <summary>
        /// Saves the data displayed in the canvas as a bitmap file
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SaveBmp(object sender, RoutedEventArgs e)
        {
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Bitmap Files | *.bmp", DefaultExt = "bmp"};
            if ((bool) sfd.ShowDialog())
            {
                var px = new byte[FrameWidth*FrameHeight*3*4];
                for (int i = 0; i < FrameHeight*2; i++)
                {
                    for (int j = 0; j < FrameWidth*2; j++)
                    {
                        px[3*i*FrameWidth*2 + 3*j] = _imageData[i, j].R;
                        px[3*i*FrameWidth*2 + 3*j + 1] = _imageData[i, j].G;
                        px[3*i*FrameWidth*2 + 3*j + 2] = _imageData[i, j].B;
                    }
                }
                BitmapSource bms = BitmapSource.Create(FrameWidth*2, FrameHeight*2, 96, 96, PixelFormats.Rgb24,
                                                       BitmapPalettes.Halftone256, px, FrameWidth*3*2);
                var be = new BmpBitmapEncoder();
                be.Frames.Add(BitmapFrame.Create(bms));
                var fs = new FileStream(sfd.FileName, FileMode.Create);
                be.Save(fs);
                fs.Close();
            }
        }

        /// <summary>
        /// Saves image data in a text file.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SaveTxt(object sender, RoutedEventArgs e)
        {
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            if ((bool) sfd.ShowDialog())
            {
                string output = "";
                for (int row = 0; row < FrameHeight; row++)
                {
                    output += String.Format("{0} {1} ", row, _adcSData[row]);
                    for (int col = 0; col < FrameWidth; col++)
                    {
                        output += String.Format("{0} ", _itempArray[row, col]);
                    }
                    output += "\n";
                }
                File.WriteAllText(sfd.FileName, output, Encoding.ASCII);
            }
        }

        /// <summary>
        /// Write a control byte to the FTDI chip
        /// </summary>
        /// <param name="ftControlByte">Byte to write to the open chip</param>
        private void FtWriteControlByte(byte ftControlByte)
        {
            FTDI.FT_STATUS ftIOStatus;
            uint writeResult = 0;
            var w = new byte[1];
            w[0] = ftControlByte;
            ftIOStatus = _ftHandle.Write(w, 1, ref writeResult);
            if (ftIOStatus != FTDI.FT_STATUS.FT_OK)
            {
                FtErrorReport("FT_Write", ftIOStatus);
            }
            if (writeResult != 1)
            {
                MessageBox.Show("WriteControl: could not write the control signal!", "Error", MessageBoxButton.OK,
                                MessageBoxImage.Error);
            }
        }

        /// <summary>
        /// Opens the devices dialog so someone can open a device port.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DoOpenPort(object sender, RoutedEventArgs e)
        {
            if (_portOpen)
            {
                OpenPort.IsEnabled = false;
                ClosePort.IsEnabled = true;
                MessageBox.Show("Port already open!", "Warning", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                return;
            }
            _deviceForm = new FrmDevice();
            _deviceForm.ShowDialog();
            if (_deviceForm.SelectedDeviceResult == FrmDevice.DEVICE_OPEN)
            {
                if (_ftHandle == null)
                    _ftHandle = new FTDI();
                FTDI.FT_STATUS r = _ftHandle.OpenByIndex(_deviceForm.SelectedDeviceIndex);
                if (r != FTDI.FT_STATUS.FT_OK)
                {
                    FtErrorReport("Open_USB_Device_By_Index", r);
                }
                else
                {
                    _portOpen = true;
                    OpenPort.IsEnabled = false;
                    ClosePort.IsEnabled = true;
                }
            }
        }

        /// <summary>
        /// Closes the open port (if any).
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DoClosePort(object sender, RoutedEventArgs e)
        {
            if (_ftHandle == null || (!_portOpen && !_ftHandle.IsOpen))
            {
                OpenPort.IsEnabled = true;
                ClosePort.IsEnabled = false;
                MessageBox.Show("Port isn't open!", "Warning", MessageBoxButton.OK, MessageBoxImage.Exclamation);
                return;
            }
            if (_ftHandle.IsOpen)
            {
                _ftHandle.Close();
            }
            _portOpen = false;
            OpenPort.IsEnabled = true;
            ClosePort.IsEnabled = false;
        }

        /// <summary>
        /// Updates the FTDI chip with new data values from the form.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void UpdateDut(object sender, RoutedEventArgs e)
        {
            if (!_portOpen) return;
            // Load data from form
            byte[] dataArray = LoadDACArray();
            FtWriteControlByte(0xFF);
            // Write the data to the chip
            FtWriteDacData(dataArray);
        }

        /// <summary>
        /// Writes the control array (MUST be a byte[25]) to the chip
        /// </summary>
        /// <param name="dataArray">The data to be written</param>
        private void FtWriteDacData(byte[] dataArray)
        {
            uint writeResult = 0;
            const int dacSize = 25;
            if (dataArray.Length != dacSize)
            {
                // Fail if the data array is the wrong length.
                MessageBox.Show("DAC array was the wrong size.", "ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            _ftHandle.Write(dataArray, dacSize, ref writeResult);
        }

        /// <summary>
        /// Loads form data into an array that can be passed into the chip's DAC.
        /// </summary>
        /// <returns>The array for the DAC</returns>
        private byte[] LoadDACArray()
        {
            UInt16 my16BitData;
            byte my8BitData;
            var dataArray = new byte[25];

            my16BitData = (UInt16)PDAC1_SB.Value;
            dataArray[1] = (byte)(my16BitData & 0x00FF);
            dataArray[0] = (byte)((my16BitData >> 8) & 0x00FF);

            my16BitData = (UInt16)PDAC2_SB.Value;
            dataArray[3] = (byte)(my16BitData & 0x00FF);
            dataArray[2] = (byte)((my16BitData >> 8) & 0x00FF);

            my16BitData = (UInt16)PDAC3_SB.Value;
            dataArray[5] = (byte)(my16BitData & 0x00FF);
            dataArray[4] = (byte)((my16BitData >> 8) & 0x00FF);

            my16BitData = (UInt16)(PDAC3_SB.Value - _event2);
            dataArray[7] = (byte)(my16BitData & 0x00FF);
            dataArray[6] = (byte)((my16BitData >> 8) & 0x00FF);

            dataArray[8] = (byte)gain_updown.SelectedIndex;
            dataArray[9] = (byte)iref_updown.SelectedIndex;
            dataArray[10] = 0;
            dataArray[11] = 0;
            dataArray[12] = 0;
            dataArray[13] = 0;
            dataArray[14] = (byte)Math.Round((double)_irefoutSpinner.Value);
            dataArray[15] = (byte)Math.Round((double)_compbiasSpinner.Value);
            dataArray[16] = (byte)Math.Round((double)_ampbiasSpinner.Value);
            dataArray[17] = (byte)Math.Round((double)_vlnSpinner.Value);
            dataArray[18] = (byte)Math.Round((double)_eventbiasSpinner.Value);
            dataArray[19] = (byte)Math.Round((double)_magbiasSpinner.Value);
            dataArray[20] = (byte)Math.Round((double)_stepSpinner.Value);
            dataArray[21] = (byte)mag_updown.SelectedIndex;

            my8BitData = 0;
            if ((bool)watermark_en.IsChecked) my8BitData |= 0x01;
            if ((bool)override_en.IsChecked) my8BitData |= 0x02;
            if ((bool)ref_pwron.IsChecked) my8BitData |= 0x04;
            if ((bool)force_en.IsChecked) my8BitData |= 0x08;
            if ((bool)power_shot.IsChecked) my8BitData |= 0x10;
            if ((bool)fast_slow.IsChecked) my8BitData |= 0x20;
            if ((bool)pstep0.IsChecked) my8BitData |= 0x40;
            if ((bool)pstep1.IsChecked) my8BitData |= 0x80;
            dataArray[22] = my8BitData;
            my8BitData = (byte)(((byte)osc_updown.SelectedIndex) & 0x07);
            if ((bool)boost_en.IsChecked) my8BitData |= 0x08;
            if ((bool)rstep0.IsChecked) my8BitData |= 0x10;
            if ((bool)rstep1.IsChecked) my8BitData |= 0x20;
            dataArray[23] = my8BitData;
            dataArray[24] = (byte)((byte)_thresholdSpinner.Value & 0x7F);

            return dataArray;
        }

        /// <summary>
        /// Saves the data currently entered into the form to an INI file that can be loaded back in later
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SaveINI(object sender, RoutedEventArgs e)
        {
            var sfd = new SaveFileDialog
                          {AddExtension = true, Filter = "Configuration Files | *.ini", DefaultExt = "ini"};
            byte[] dArray = LoadDACArray();
            string output = "";
            if ((bool) sfd.ShowDialog() == false)
                return;
            for (int i = 0; i < dArray.Length; i++)
            {
                output += String.Format("{0}\n", dArray[i].ToString());
            }
            File.WriteAllText(sfd.FileName, output, Encoding.ASCII);
        }

        /// <summary>
        /// Fills the form with data from a valid DAC array.
        /// </summary>
        /// <param name="dataArray">An array that can be safely passed to the DAC</param>
        private void SetDefaultValues(byte[] dataArray)
        {
            byte my8BitData;
            PDAC1_SB.Value = dataArray[0]*256 + dataArray[1];
            PDAC2_SB.Value = dataArray[2]*256 + dataArray[3];
            PDAC3_SB.Value = dataArray[4]*256 + dataArray[5];
            int tmp = dataArray[6]*256 + dataArray[7];
            _event2 = (int) PDAC3_SB.Value - tmp;
            gain_updown.SelectedIndex = dataArray[8] & 0x07;
            iref_updown.SelectedIndex = dataArray[9] & 0x07;
            if (iref_updown.SelectedIndex == 0) _xbi = 0.333;
            if (iref_updown.SelectedIndex == 1) _xbi = 0.239;
            if (iref_updown.SelectedIndex == 2) _xbi = 0.264;
            if (iref_updown.SelectedIndex == 3) _xbi = 0.294;
            if (iref_updown.SelectedIndex == 4) _xbi = 0.378;
            if (iref_updown.SelectedIndex == 5) _xbi = 0.442;
            if (iref_updown.SelectedIndex == 6) _xbi = 0.529;
            if (iref_updown.SelectedIndex == 7) _xbi = 0.657;

            _irefoutSpinner.Value = (dataArray[14] & 0x3F);
            _compbiasSpinner.Value = (dataArray[15] & 0x3F);
            _ampbiasSpinner.Value = (dataArray[16] & 0x3F);
            _vlnSpinner.Value = (dataArray[17] & 0x3F);
            _eventbiasSpinner.Value = (dataArray[18] & 0x3F);
            _magbiasSpinner.Value = (dataArray[19] & 0x3F);
            _stepSpinner.Value = (dataArray[20] & 0xFF);
            mag_updown.SelectedIndex = (dataArray[21] & 0x07);

            my8BitData = dataArray[22];
            watermark_en.IsChecked = ((my8BitData & 0x01) == 0x01);
            override_en.IsChecked = ((my8BitData & 0x02) == 0x02);
            ref_pwron.IsChecked = ((my8BitData & 0x04) == 0x04);
            force_en.IsChecked = ((my8BitData & 0x08) == 0x08);
            power_shot.IsChecked = ((my8BitData & 0x10) == 0x10);
            fast_slow.IsChecked = ((my8BitData & 0x20) == 0x20);
            pstep0.IsChecked = ((my8BitData & 0x40) == 0x40);
            pstep1.IsChecked = ((my8BitData & 0x80) == 0x80);

            osc_updown.SelectedIndex = dataArray[23] & 0x07;

            my8BitData = dataArray[23];
            boost_en.IsChecked = ((my8BitData & 0x08) == 0x08);
            rstep0.IsChecked = ((my8BitData & 0x10) == 0x10);
            rstep1.IsChecked = ((my8BitData & 0x20) == 0x20);

            _thresholdSpinner.Value = dataArray[24] & 0x7F;

            UpdownMenus();
        }

        /// <summary>
        /// Loads sensible default values into the form.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void LoadDEF(object sender = null, RoutedEventArgs e = null)
        {
            var dataArray = new byte[25];
            _event2 = 0;
            dataArray[0] = 0x9B;
            dataArray[1] = 0x30;
            dataArray[2] = 0x9B;
            dataArray[3] = 0x30;
            dataArray[4] = 0x80;
            dataArray[5] = 0x00;
            dataArray[6] = 0x80;
            dataArray[7] = 0x00;
            dataArray[8] = 0x00;
            dataArray[9] = 0x00;
            dataArray[10] = 0x00;
            dataArray[11] = 0x00;
            dataArray[12] = 0x02;
            dataArray[13] = 0x00;
            dataArray[14] = 0x00;
            dataArray[15] = 0x1B;
            dataArray[16] = 0x1E;
            dataArray[17] = 0x10;
            dataArray[18] = 0x20;
            dataArray[19] = 0x00;
            dataArray[20] = 0x00;
            dataArray[21] = 0x00;
            dataArray[22] = 0x34;
            dataArray[23] = 0x0A;
            dataArray[24] = 0x00;
            SetDefaultValues(dataArray);
        }

        /// <summary>
        /// Opens an INI file containing DAC data, and populates the form with that data.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void LoadINI(object sender, RoutedEventArgs e)
        {
            var ofd = new OpenFileDialog
                          {AddExtension = true, Filter = "Configuration Files | *.ini", DefaultExt = "ini"};
            if ((bool) ofd.ShowDialog() == false)
                return;
            string[] lines = File.ReadAllLines(ofd.FileName);
            int i = 0;
            byte[] dataArray = (from string line in lines where (i++ < 25) select Byte.Parse(line)).ToArray();
            if (dataArray.Length != 25)
            {
                MessageBox.Show("Invalid INI File", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            SetDefaultValues(dataArray);
        }

        /// <summary>
        /// Called when a GAMMA slider is changed.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SbGammaChange(object sender, RoutedPropertyChangedEventArgs<double> e = null)
        {
            if (EGamma == null) return;
            int i;
            double axGamma;
            _gamma = (SBGamma.Maximum - (SBGamma.Value - SBGamma.Minimum))/100;
            _gammaTable[0] = 0;
            for (i = 0; i < 256; i++)
            {
                _gammaTable[i] = (byte) Math.Round(255*Math.Exp(_gamma*Math.Log(i/255.0, Math.E)));
            }
            EGamma.Text = _gamma.ToString("0.00");
            axGamma = (ADC_Gamma.Maximum - (ADC_Gamma.Value - ADC_Gamma.Minimum))/100;
            AGamma.Text = axGamma.ToString("0.00");
            _aGammaTable[0] = 0;
            for (i = 0; i < 1024; i++)
            {
                if ((bool) Amap_en.IsChecked)
                    _aGammaTable[i] = (byte) Math.Round(255*Math.Pow(i/1024.0, axGamma));
                else
                    _aGammaTable[i] = (byte) i;
            }
        }

        /// <summary>
        /// Shows the about dialog (main form is unusable until it closes).
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ShowAbout(object sender, RoutedEventArgs e)
        {
            About abt = new About();
            abt.ShowDialog();
        }

        /// <summary>
        /// Called when the DAC slider values change.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SliderMenus(object sender, RoutedPropertyChangedEventArgs<double> e)
        {
            if (!_loadcomplete) return;
            if (sender == PDAC1_SB)
            {
                pdac1_text.Text = (e.NewValue*0.00005087).ToString("0.0000");
            }
            if (sender == PDAC2_SB)
            {
                pdac2_text.Text = (e.NewValue*0.00005084).ToString("0.0000");
            }
            if (sender == PDAC3_SB)
            {
                pdac3_text.Text = (e.NewValue*0.00005087).ToString("0.0000");
                pdac4_text.Text = ((e.NewValue - _event2)*0.00005087).ToString("0.0000");
            }
            UpdownMenus();
        }

        /// <summary>
        /// Common function for use when it is necessary to update the text for UpDown menus (e.g. when a spinner is clicked).
        /// </summary>
        private void UpdownMenus()
        {
            if (!_loadcomplete) return;
            switch(iref_updown.SelectedIndex)
            {
                case 0: _xbi = 0.333; irefout_text.Text = "0:0.333u"; break;
                case 1: _xbi = 0.239; irefout_text.Text = "1:0.239u"; break;
                case 2: _xbi = 0.264; irefout_text.Text = "2:0.264u"; break;
                case 3: _xbi = 0.294; irefout_text.Text = "3:0.294u"; break;
                case 4: _xbi = 0.378; irefout_text.Text = "4:0.378u"; break;
                case 5: _xbi = 0.442; irefout_text.Text = "5:0.442u"; break;
                case 6: _xbi = 0.529; irefout_text.Text = "6:0.529u"; break;
                case 7: _xbi = 0.657; irefout_text.Text = "7:0.657u"; break;
            }
            switch (gain_updown.SelectedIndex)
            {
                case 0: _gainsett = 8.23; break;
                case 1: _gainsett = 4.11; break;
                case 2: _gainsett = 2.74; break;
                case 3: _gainsett = 2.06; break;
                case 4: _gainsett = 1.5; break;
                case 5: _gainsett = 1.27; break;
                case 6: _gainsett = 1.1; break;
                case 7: _gainsett = 0.97; break;
            }

            if (_vlnSpinner.Value == 0) vln_text.Text = "OFF";
            else vln_text.Text = (_vlnSpinner.Value*_xbi).ToString("0.00") + "uA";
            if (_magbiasSpinner.Value == 0) magbias_text.Text = "OFF";
            else magbias_text.Text = (_magbiasSpinner.Value*_xbi*3).ToString("0.00") + "uA";
            if (_ampbiasSpinner.Value == 0) ampbias_text.Text = "OFF";
            else ampbias_text.Text = (_ampbiasSpinner.Value*_xbi*1.5).ToString("0.00") + "uA";
            if (_irefoutSpinner.Value == 0) irefout_text.Text = "OFF";
            else irefout_text.Text = (_irefoutSpinner.Value*_xbi).ToString("0.00") + "uA";
            if (_compbiasSpinner.Value == 0) compbias_text.Text = "OFF";
            else compbias_text.Text = (_compbiasSpinner.Value*_xbi*1.5).ToString("0.00") + "uA";
            if (_eventbiasSpinner.Value == 0) eventbias_text.Text = "OFF";
            else eventbias_text.Text = (_eventbiasSpinner.Value*_xbi*16).ToString("0.00") + "uA";
            threshold_text.Text = _thresholdSpinner.Value.ToString();
            step_text.Text = _stepSpinner.Value.ToString();

            double tmp = _thresholdSpinner.Value;
            _event2 = (int) (19.8594*tmp*(0.00001271*tmp*tmp*tmp - 0.0013069*tmp*tmp + 0.15949588*tmp + 14.41845));
            if (_event2 > PDAC3_SB.Value) _event2 = (int)PDAC3_SB.Value;
            pdac4_text.Text = ((PDAC3_SB.Value - _event2)*0.00005087).ToString("0.0000");
        }

        /// <summary>
        /// Called when a DAC ComboBox is changed.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void UpdownMenusC(object sender, SelectionChangedEventArgs e)
        {
            UpdownMenus();
        }

        /// <summary>
        /// Called to run the async process (and start general analysis / image capture)
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void RunPrgWrapper(object sender, RoutedEventArgs e)
        {
            if (!_portOpen) return;
            _bw.WorkerReportsProgress = true;
            _bw.WorkerSupportsCancellation = true;

            if (!_bw.IsBusy)
            {
                _bw.RunWorkerAsync();
            }
        }

        /// <summary>
        /// Called to stop the program (and verifies that the port is open).
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void StopPrgWrapper(object sender, RoutedEventArgs e)
        {
            if (!_portOpen) return;
            StopPrg();
        }

        /// <summary>
        /// Called from inside all async processes in order to access main form components.
        /// The async process CANNOT access any form elements directly.  To invoke, use:
        /// EXEC(new Action(delegate { /* CODE HERE */ }));
        /// </summary>
        /// <param name="method">The Action delegate to execute</param>
        private void EXEC(Delegate method)
        {
            Application.Current.Dispatcher.Invoke(DispatcherPriority.Normal, method);
        }

        /// <summary>
        /// Called by the BackgroundWorker when it is started (and the program should be run).
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void BwDoWork(object sender, DoWorkEventArgs e)
        {
            EXEC(new Action(delegate
                                {
                                    bn_Run.IsEnabled = false;
                                    bn_Stop.IsEnabled = true;
                                    RunMenu.IsEnabled = false;
                                    StopMenu.IsEnabled = true;
                                }));
            RunPrg();
        }

        private void SetLabelValue(Label l, double d)
        {
            if (d >= 1000 || d < 1)
            {
                //use B
                l.Content = d.ToString(LabelFormatB);
            }
            else
            {
                l.Content = d.ToString(LabelFormatA);
            }
        }

        /// <summary>
        /// Main execution loop for receipt and analysis of imaging data.
        /// Should ONLY be called by BwDoWork or another async process to prevent the form from freezing.
        /// Use the EXEC method to access form elements.
        /// </summary>
        private void RunPrg()
        {
            FTDI.FT_STATUS portStatus, ftIOStatus;
            uint readCount, readResult, ftBufCount;
            byte c;
            int row, col, cc, dmin, dmax, i, j, cf, ddark;
            int temprow, tempcol, tty;
            int streamno = 0;
            string streamname;
            double it, itCap;
            var imageArray = new byte[FrameHeight,FrameWidth];
            var iImageArray = new int[FrameHeight,FrameWidth];
            var parNAvrg = new double[MaxFrameNum];
            var parNRowAvrg = new double[MaxFrameNum,FrameHeight];
            var parNColAvrg = new double[MaxFrameNum,FrameWidth - 1];
            var parRowAvrg = new double[FrameHeight];
            var parColAvrg = new double[FrameWidth];
            int frameno, fanalyze, numberOfFrames, fr;
            double ftmp1;

            readCount = 150*201*2 + 3;
            _videoActive = true;
            frameno = 0;
            fanalyze = 0;
            _ftQBytes = 0;
            readResult = 0;

            int oscUpdownVal = 0;
            numberOfFrames = 0;
            bool defectCheckBoxVal = false;
            bool showanaboxVal = false;
            bool blueDotboxVal = false;
            bool nperconvertVal = false;
            bool nconvertVal = false;
            bool subDarkVal = false;
            bool amapEnVal = false;
            bool vflipVal = false;
            bool hflipVal = false;
            bool analysisBoxVal = false;
            bool videoSaveBoxVal = false;
            bool inputReferedVal = false;

            //DateTime da;

            do
            {
                EXEC(new Action(delegate
                                    {
                                        oscUpdownVal = osc_updown.SelectedIndex;
                                        defectCheckBoxVal = (bool) DefectCheckBox.IsChecked;
                                        showanaboxVal = (bool) showanabox.IsChecked;
                                        blueDotboxVal = (bool) blue_dotbox.IsChecked;
                                        _xstr = int.Parse(xbas.Text);
                                        _ystr = int.Parse(ybas.Text);
                                        _dx = int.Parse(deltax.Text);
                                        _dy = int.Parse(deltay.Text);
                                        numberOfFrames = int.Parse(num_frames.Text);
                                        nperconvertVal = (bool) Nperconvert.IsChecked;
                                        nconvertVal = (bool) Nconvert.IsChecked;
                                        subDarkVal = (bool) sub_dark.IsChecked;
                                        amapEnVal = (bool) Amap_en.IsChecked;
                                        vflipVal = (bool) Vflip.IsChecked;
                                        hflipVal = (bool) Hflip.IsChecked;
                                        analysisBoxVal = (bool) analysis_box.IsChecked;
                                        videoSaveBoxVal = (bool) Video_SaveBox.IsChecked;
                                        inputReferedVal = (bool) input_refered.IsChecked;
                                    }));

                if (_adcTestActive) _videoActive = false;
                FtWriteControlByte(0x0F);
                //da = DateTime.Now;
                do
                {
                    portStatus = _ftHandle.GetRxBytesAvailable(ref _ftQBytes);
                    if (portStatus != FTDI.FT_STATUS.FT_OK)
                        FtErrorReport("FT_GetQueueStatus", portStatus);
                } while (_ftQBytes < readCount);

                /*EXEC(new Action(delegate
                {
                    TimeSpan ta = DateTime.Now - da;
                    Memo1.AppendText(ta.Seconds.ToString() + "." + ta.Milliseconds.ToString("000") + " seconds to wait\n");
                    Memo1.ScrollToEnd();
                }));

                da = DateTime.Now;*/

                ftIOStatus = _ftHandle.Read(_ftInBuffer, readCount, ref readResult);
                if (ftIOStatus != FTDI.FT_STATUS.FT_OK)
                    FtErrorReport("FT_Read", ftIOStatus);
                it = _ftInBuffer[60300] + 256*_ftInBuffer[60301] + 65536*_ftInBuffer[60302];
                tty = (int) it;

                /*EXEC(new Action(delegate
                                    {
                                        TimeSpan tz = DateTime.Now - da;
                                        Memo1.AppendText(tz.Seconds.ToString() + "." + tz.Milliseconds.ToString("000") + " seconds to read\n");
                                        Memo1.ScrollToEnd();
                                    }));

                da = DateTime.Now;*/

                switch (oscUpdownVal)
                {
                    case 1:
                        itCap = it/4000;
                        break;
                    case 2:
                        itCap = it/10000;
                        break;
                    case 3:
                        itCap = it/12000;
                        break;
                    case 4:
                        itCap = it/16000;
                        break;
                    case 5:
                        itCap = it/20000;
                        break;
                    default:
                        itCap = it/10000;
                        break;
                }
                EXEC(new Action(delegate
                                    {
                                        ttyp_label.Content = tty.ToString();
                                        it_caption.Content = String.Format("/{0} ms", ((int) itCap).ToString("000"));
                                        fps_caption.Content = (1000/itCap).ToString("0.00");
                                    }));
                ftBufCount = 0;
                for (row = 0; row < FrameHeight; row++)
                {
                    c = _ftInBuffer[ftBufCount];
                    ftBufCount++;
                    cc = c + 256*_ftInBuffer[ftBufCount];
                    ftBufCount++;
                    _adcSData[row] = (int) Math.Round(cc/32.0);
                    for (col = 0; col < FrameWidth; col++)
                    {
                        c = _ftInBuffer[ftBufCount];
                        ftBufCount++;
                        cc = c + 256*(_ftInBuffer[ftBufCount] & 0x03);
                        _tempArray[row, col] = c;
                        _itempArray[row, col] = cc;
                        ftBufCount++;
                    }
                }

                if (_useDefectData && defectCheckBoxVal)
                {
                    for (cf = 0; cf < 30000; cf++)
                    {
                        i = _defectArrayY[cf];
                        j = _defectArrayX[cf];
                        if (i > 0 && j > 0 && j < FrameWidth - 1 && i < FrameHeight - 1)
                        {
                            _itempArray[i, j] = (int) Math.Round((_itempArray[i - 1, j - 1] +
                                                                 _itempArray[i - 1, j] + _itempArray[i - 1, j + 1] +
                                                                 _itempArray[i, j - 1] + _itempArray[i, j + 1] +
                                                                 _itempArray[i + 1, j - 1] + _itempArray[i + 1, j] +
                                                                 _itempArray[i + 1, j + 1])/8.0);
                            _tempArray[i, j] = (byte) Math.Round((_tempArray[i - 1, j - 1] +
                                                                 _tempArray[i - 1, j] + _tempArray[i - 1, j + 1] +
                                                                 _tempArray[i, j - 1] + _tempArray[i, j + 1] +
                                                                 _tempArray[i + 1, j - 1] + _tempArray[i + 1, j] +
                                                                 _tempArray[i + 1, j + 1])/8.0);
                        }
                    }
                }

                dmin = 1023;
                for (row = 0; row < FrameHeight; row++)
                    for (col = 0; col < FrameWidth; col++)
                        if (_itempArray[row, col] < dmin && _itempArray[row, col] > 0)
                            dmin = _itempArray[row, col];

                ddark = 0;
                for (row = 0; row < FrameHeight; row++)
                    ddark += _itempArray[row, 1];
                for (col = 0; col < FrameWidth; col++)
                    ddark += _itempArray[1, col];
                ddark = ddark/350;
                EXEC(new Action(delegate { Dark_level.Content = ddark.ToString(); }));

                if (ddark > dmin + 2)
                    ddark = dmin - 2;

                for (row = 0; row < FrameHeight; row++)
                {
                    for (col = 0; col < FrameWidth; col++)
                    {
                        if (subDarkVal)
                        {
                            cc = _itempArray[row, col] - ddark;
                        }
                        else
                        {
                            cc = _itempArray[row, col];
                        }
                        _itempArray[row, col] = cc;
                        if (amapEnVal)
                        {
                            _tempArray[row, col] = _aGammaTable[cc];
                        }
                        _rawData[row, col] = _tempArray[row, col];
                    }
                }

                for (row = 0; row < FrameHeight; row++)
                {
                    for (col = 0; col < FrameWidth; col++)
                    {
                        bool v = vflipVal;
                        bool h = hflipVal;
                        if (v && h)
                        {
                            imageArray[row, col] = _tempArray[FrameHeight - 1 - row, FrameWidth - 1 - col];
                            iImageArray[row, col] = _itempArray[FrameHeight - 1 - row, FrameWidth - 1 - col];
                        }
                        if (v && !h)
                        {
                            imageArray[row, col] = _tempArray[FrameHeight - 1 - row, col];
                            iImageArray[row, col] = _itempArray[FrameHeight - 1 - row, col];
                        }
                        if (!v && h)
                        {
                            imageArray[row, col] = _tempArray[row, FrameWidth - 1 - col];
                            iImageArray[row, col] = _itempArray[row, FrameWidth - 1 - col];
                        }
                        if (!v && !h)
                        {
                            imageArray[row, col] = _tempArray[row, col];
                            iImageArray[row, col] = _itempArray[row, col];
                        }
                    }
                }

                for (row = 0; row < FrameHeight; row++)
                {
                    for (col = 0; col < FrameWidth; col++)
                    {
                        _tempArray[row, col] = imageArray[row, col];
                        _itempArray[row, col] = iImageArray[row, col];
                    }
                }

                /*EXEC(new Action(delegate
                {
                    TimeSpan tx = DateTime.Now - da;
                    Memo1.AppendText(tx.Seconds.ToString() + "." + tx.Milliseconds.ToString("000") + " seconds to process\n");
                    Memo1.ScrollToEnd();
                }));

                da = DateTime.Now;*/


                for (row = 0; row < FrameHeight; row++)
                {
                    for (col = 0; col < FrameWidth; col++)
                    {
                        c = imageArray[row, col];
                        i = 0;
                        j = 0;
                        EXEC(new Action(delegate
                                            {
                                                i = int.Parse(pixy.Text);
                                                j = int.Parse(pixx.Text);
                                            }));
                        for (temprow = 0; temprow < 2; temprow++)
                        {
                            for (tempcol = 0; tempcol < 2; tempcol++)
                            {
                                if ((
                                        ((col == _xstr - 1) && (row < _ystr + _dy + 1) && (row > _ystr - 2)) ||
                                        ((col == _xstr + _dx) && (row < _ystr + _dy + 1) && (row > _ystr - 2)) ||
                                        ((row == _ystr - 1) && (col < _xstr + _dx + 1) && (col > _xstr - 2)) ||
                                        ((row == _ystr + _dy) && (col < _xstr + _dx + 1) && (col > _xstr - 2))) &&
                                    showanaboxVal
                                    )
                                {
                                    _imageData[row*2 + temprow, col*2 + tempcol] = Color.Red;
                                }
                                else
                                {
                                    _imageData[row*2 + temprow, col*2 + tempcol] =
                                        Color.FromArgb(_gammaTable[c], _gammaTable[c], _gammaTable[c]);
                                }
                                if (!blueDotboxVal)
                                {
                                    _imageData[i*2 + temprow, j*2 + tempcol] = Color.Blue;
                                }
                                _bmPx2Data[row*2 + temprow, col*2 + tempcol] = _gammaTable[c];
                            }
                        }
                    }
                }


                if (numberOfFrames > 49)
                    numberOfFrames = 49;
                if (numberOfFrames < 2)
                    numberOfFrames = 2;

                EXEC(new Action(delegate
                                    {
                                        num_frames.Text = numberOfFrames.ToString();
                                        Memo1.AppendText(String.Format("frame {0}\n", frameno.ToString()));
                                        Memo1.ScrollToEnd();
                                    }));


                dmin = 1023;
                dmax = 0;

                for (row = _ystr - 1; row < _ystr + _dy; row++)
                {
                    for (col = _xstr - 1; col < _xstr + _dx; col++)
                    {
                        if ((_itempArray[row, col] > dmax) && (_itempArray[row, col] < 1023))
                            dmax = _itempArray[row, col];
                        if ((_itempArray[row, col] < dmin) && (_itempArray[row, col] > 0))
                            dmin = _itempArray[row, col];
                    }
                }

                if (inputReferedVal)
                {
                    EXEC(new Action(delegate
                                        {
                                            dmin_caption.Content = ((int) (dmin/_gainsett)).ToString();
                                            dmax_caption.Content = ((int) (dmax/_gainsett)).ToString();
                                        }));
                }
                else
                {
                    EXEC(new Action(delegate
                                        {
                                            dmin_caption.Content = (dmin).ToString();
                                            dmax_caption.Content = (dmax).ToString();
                                        }));
                }


                for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                {
                    ftmp1 = 0.0;
                    for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                    {
                        ftmp1 += _itempArray[row, col];
                    }
                    parNColAvrg[frameno, col] = ftmp1/_dy;
                }
                for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                {
                    ftmp1 = 0;
                    for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                    {
                        ftmp1 += _itempArray[row, col];
                    }
                    parNRowAvrg[frameno, row] = ftmp1/_dx;
                }

                if (fanalyze == 1)
                {
                    _fullNframeAvrg = 0.0;
                    for (fr = 0; fr < numberOfFrames - 1; fr++)
                    {
                        ftmp1 = 0;
                        for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                        {
                            for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                            {
                                _fullNframeAvrg += _imageFArray[fr, row, col];
                                ftmp1 += _imageFArray[fr, row, col];
                            }
                        }
                        parNAvrg[fr] = ftmp1/(_dx*_dy);
                    }
                    _fullNframeAvrg /= (_dx*_dy*numberOfFrames);
                    if (inputReferedVal)
                    {
                        EXEC(
                            new Action(() => SetLabelValue(Navrg_caption, (_fullNframeAvrg/_gainsett))));
                    }
                    else
                    {
                        EXEC(new Action(() =>SetLabelValue(Navrg_caption, _fullNframeAvrg)));
                    }

                    for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                    {
                        for (col = _xstr; col < _xstr + _dx - 1; col++)
                        {
                            ftmp1 = 0.00;
                            for (fr = 0; fr < numberOfFrames - 1; fr++)
                            {
                                ftmp1 += _imageFArray[fr, row, col];
                            }
                            _imageAfArray[row, col] = ftmp1/numberOfFrames;
                        }
                    }

                    for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                    {
                        ftmp1 = 0.0;
                        for (fr = 0; fr < numberOfFrames - 1; fr++)
                        {
                            ftmp1 += parNRowAvrg[fr, row];
                            parRowAvrg[row] = ftmp1/numberOfFrames;
                        }
                    }

                    for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                    {
                        ftmp1 = 0.0;
                        for (fr = 0; fr < numberOfFrames - 1; fr++)
                        {
                            ftmp1 += parNColAvrg[fr, col];
                            parColAvrg[col] = ftmp1/numberOfFrames;
                        }
                    }

                    _ftotalNoise = 0;
                    _ftempNoise = 0;
                    for (fr = 0; fr < numberOfFrames - 1; fr++)
                    {
                        _ftotalFpn = 0;
                        for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                        {
                            for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                            {
                                _ftotalNoise += Math.Pow(_imageFArray[fr, row, col] - _fullNframeAvrg, 2);
                                _ftempNoise += Math.Pow(_imageFArray[fr, row, col] - _imageAfArray[row, col], 2);
                                _ftotalFpn += Math.Pow(_imageAfArray[row, col] - _fullNframeAvrg, 2);
                            }
                        }
                    }
                    _ftotalNoise /= (_dx*_dy*numberOfFrames);
                    _ftempNoise /= (_dx*_dy*numberOfFrames);
                    _ftotalFpn /= (_dx*_dy);
                    if (inputReferedVal)
                    {
                        _ftotalNoise /= (_gainsett*_gainsett);
                        _ftempNoise /= (_gainsett*_gainsett);
                        _ftotalFpn /= (_gainsett*_gainsett);
                        EXEC(new Action(delegate { infolabel3.Content = "Input"; }));
                    }
                    else
                    {
                        EXEC(new Action(delegate { infolabel3.Content = "Output"; }));
                    }

                    if (nconvertVal)
                    {
                        _ftotalNoise = Math.Sqrt(_ftotalNoise);
                        _ftempNoise = Math.Sqrt(_ftempNoise);
                        _ftotalFpn = Math.Sqrt(_ftotalFpn);
                        EXEC(new Action(delegate
                                            {
                                                infolabel2.Content = " ";
                                                infolabel4.Content = "Noise Voltage";
                                            }));
                    }
                    else
                    {
                        EXEC(new Action(delegate
                                            {
                                                infolabel2.Content = "2";
                                                infolabel4.Content = "Squared Noise";
                                            }));
                    }

                    if (nperconvertVal)
                    {
                        _ftotalNoise *= 100/_fullNframeAvrg;
                        _ftempNoise *= 100/_fullNframeAvrg;
                        _ftotalFpn *= 100/_fullNframeAvrg;
                        EXEC(new Action(delegate { infolabel1.Content = "%LSB"; }));
                    }
                    else
                    {
                        EXEC(new Action(delegate { infolabel1.Content = "    LSB"; }));
                    }

                    EXEC(new Action(delegate
                                        {
                                            SetLabelValue(FtotalNoise_caption, _ftotalNoise);
                                            SetLabelValue(FtempNoise_caption, _ftempNoise);
                                            SetLabelValue(FtotalFPN_caption, _ftotalFpn);
                                        }));


                    _rtotalNoise = 0.0;
                    _rtempNoise = 0.0;
                    for (fr = 0; fr < numberOfFrames - 1; fr++)
                    {
                        _rtotalFpn = 0;
                        for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                        {
                            _rtotalNoise += Math.Pow(parNRowAvrg[fr, row] - _fullNframeAvrg, 2);
                            _rtempNoise += Math.Pow(parNRowAvrg[fr, row] - parRowAvrg[row], 2);
                            _rtotalFpn += Math.Pow(parRowAvrg[row] - _fullNframeAvrg, 2);
                        }
                    }
                    _rtotalNoise /= (_dy*numberOfFrames);
                    _rtempNoise /= (_dy*numberOfFrames);
                    _rtotalFpn /= _dy;

                    if (inputReferedVal)
                    {
                        _rtotalNoise /= (_gainsett*_gainsett);
                        _rtempNoise /= (_gainsett*_gainsett);
                        _rtotalFpn /= (_gainsett*_gainsett);
                    }

                    if (nconvertVal)
                    {
                        _rtotalNoise = Math.Sqrt(_rtotalNoise);
                        _rtempNoise = Math.Sqrt(_rtempNoise);
                        _rtotalFpn = Math.Sqrt(_rtotalFpn);
                    }

                    if (nperconvertVal)
                    {
                        _rtotalNoise *= 100/_fullNframeAvrg;
                        _rtempNoise *= 100/_fullNframeAvrg;
                        _rtotalFpn *= 100/_fullNframeAvrg;
                    }

                    EXEC(new Action(delegate
                                        {
                                            SetLabelValue(RtotalNoise_caption, _rtotalNoise);
                                            SetLabelValue(RtempNoise_caption, _rtempNoise);
                                            SetLabelValue(RtotalFPN_caption, _rtotalFpn);
                                        }));

                    _ctotalNoise = 0.0;
                    _ctempNoise = 0.0;
                    for (fr = 0; fr < numberOfFrames - 1; fr++)
                    {
                        _ctotalFpn = 0;
                        for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                        {
                            _ctotalNoise += Math.Pow(parNColAvrg[fr, col] - _fullNframeAvrg, 2);
                            _ctempNoise += Math.Pow(parNColAvrg[fr, col] - parColAvrg[col], 2);
                            _ctotalFpn += Math.Pow(parColAvrg[col] - _fullNframeAvrg, 2);
                        }
                    }
                    _ctotalNoise /= (_dx*numberOfFrames);
                    _ctempNoise /= (_dx*numberOfFrames);
                    _ctotalFpn /= _dx;

                    if (inputReferedVal)
                    {
                        _ctotalNoise /= (_gainsett*_gainsett);
                        _ctempNoise /= (_gainsett*_gainsett);
                        _ctotalFpn /= (_gainsett*_gainsett);
                    }

                    if (nconvertVal)
                    {
                        _ctotalNoise = Math.Sqrt(_ctotalNoise);
                        _ctempNoise = Math.Sqrt(_ctempNoise);
                        _ctotalFpn = Math.Sqrt(_ctotalFpn);
                    }

                    if (nperconvertVal)
                    {
                        _ctotalNoise *= 100/_fullNframeAvrg;
                        _ctempNoise *= 100/_fullNframeAvrg;
                        _ctotalFpn *= 100/_fullNframeAvrg;
                    }

                    EXEC(new Action(delegate
                                        {
                                            SetLabelValue(CtotalNoise_caption, _ctotalNoise);
                                            SetLabelValue(CtempNoise_caption, _ctempNoise);
                                            SetLabelValue(CtotalFPN_caption, _ctotalFpn);
                                        }));

                    _flickerNoise = 0;
                    for (fr = 0; fr < numberOfFrames - 1; fr++)
                    {
                        _flickerNoise += Math.Pow(parNAvrg[fr] - _fullNframeAvrg, 2);
                    }
                    _flickerNoise /= numberOfFrames;

                    if (nconvertVal)
                    {
                        _ptempNoise =
                            Math.Sqrt(
                                Math.Abs(_ftempNoise*_ftempNoise - _ctempNoise*_ctempNoise - _rtempNoise*_rtempNoise +
                                         _flickerNoise));
                        _ptotalFpn = Math.Sqrt(Math.Abs(_ftotalFpn*_ftotalFpn - _ctotalFpn*_ctotalFpn - _rtotalFpn*_rtotalFpn));
                        _ptotalNoise = Math.Sqrt(Math.Abs(_ptempNoise + _ptotalFpn));
                        _flickerNoise = Math.Sqrt(_flickerNoise);
                    }
                    else
                    {
                        _ptempNoise = Math.Abs(_ftempNoise - _ctempNoise - _rtempNoise + _flickerNoise);
                        _ptotalFpn = Math.Abs(_ftotalFpn - _ctotalFpn - _rtotalFpn);
                        _ptotalNoise = Math.Abs(_ptempNoise + _ptotalFpn);
                    }

                    if (inputReferedVal)
                    {
                        _ptotalNoise /= (_gainsett*_gainsett);
                        _ptempNoise /= (_gainsett*_gainsett);
                        _ptotalFpn /= (_gainsett*_gainsett);
                    }

                    if (nperconvertVal)
                    {
                        _ptotalNoise *= 100/_fullNframeAvrg;
                        _ptempNoise *= 100/_fullNframeAvrg;
                        _ptotalFpn *= 100/_fullNframeAvrg;
                    }

                    EXEC(new Action(delegate
                                        {
                                            SetLabelValue(PtotalNoise_caption, _ptotalNoise);
                                            SetLabelValue(PtempNoise_caption, _ptempNoise);
                                            SetLabelValue(PtotalFPN_caption, _ptotalFpn);
                                            SetLabelValue(FlickerNoise_caption, _flickerNoise);
                                        }));
                }

                if (fanalyze == 2)
                {
                    _fullframeAvrg1 = 0;
                    _fullframeAvrg2 = 0;
                    ftmp1 = 0;
                    for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                    {
                        for (col = _xstr - 1; col < _xstr + _dx - 1; col++)
                        {
                            _fullframeAvrg1 += _imageFArray[1, row, col];
                            _fullframeAvrg2 += _imageFArray[2, row, col];
                            ftmp1 += Math.Pow(_imageFArray[1, row, col] - _imageFArray[2, row, col], 2);
                        }
                    }
                    _fullframeAvrg1 /= (_dx*_dy);
                    _fullframeAvrg2 /= (_dx*_dy);
                    _ftempNoise = ftmp1/(2*_dx*_dy);

                    _fullNframeAvrg = (_fullframeAvrg1 + _fullframeAvrg2)/2;
                    EXEC(new Action(() => SetLabelValue(Navrg_caption, _fullNframeAvrg)));

                    _ftotalNoise1 = 0;
                    _ftotalNoise2 = 0;
                    for (row = _ystr - 1; row < _ystr + _dy - 1; row++)
                    {
                        for (col = _xstr; col < _xstr + _dx - 1; col++)
                        {
                            _ftotalNoise1 += Math.Pow(_imageFArray[1, row, col] - _fullframeAvrg1, 2);
                            _ftotalNoise2 += Math.Pow(_imageFArray[2, row, col] - _fullframeAvrg2, 2);
                        }
                    }
                    _ftotalNoise1 /= (_dx*_dy);
                    _ftotalNoise2 /= (_dx*_dy);
                    _ftotalNoise = Math.Pow((Math.Sqrt(_ftotalNoise1) + Math.Sqrt(_ftotalNoise2))/2, 2);
                    _ftotalFpn = _ftotalNoise - _ftempNoise;

                    if (inputReferedVal)
                    {
                        _ftotalNoise /= (_gainsett*_gainsett);
                        _ftempNoise /= (_gainsett*_gainsett);
                        _ftotalFpn /= (_gainsett*_gainsett);
                        EXEC(new Action(delegate { infolabel3.Content = "Input"; }));
                    }
                    else
                    {
                        EXEC(new Action(delegate { infolabel3.Content = "Output"; }));
                    }

                    if (nconvertVal)
                    {
                        _ftotalNoise = Math.Sqrt(_ftotalNoise);
                        _ftempNoise = Math.Sqrt(_ftempNoise);
                        _ftotalFpn = Math.Sqrt(_ftotalFpn);
                        EXEC(new Action(delegate
                                            {
                                                infolabel2.Content = " ";
                                                infolabel4.Content = "Noise Voltage";
                                            }));
                    }
                    else
                    {
                        EXEC(new Action(delegate
                                            {
                                                infolabel2.Content = "2";
                                                infolabel4.Content = "Squared Noise";
                                            }));
                    }

                    if (nperconvertVal)
                    {
                        _ftotalNoise *= 100/_fullNframeAvrg;
                        _ftempNoise *= 100/_fullNframeAvrg;
                        _ftotalFpn *= 100/_fullNframeAvrg;
                        EXEC(new Action(delegate { infolabel1.Content = "%LSB"; }));
                    }
                    else
                    {
                        EXEC(new Action(delegate { infolabel1.Content = "    LSB"; }));
                    }

                    EXEC(new Action(delegate
                                        {
                                            SetLabelValue(FtotalNoise_caption, _ftotalNoise);
                                            SetLabelValue(FtempNoise_caption, _ftempNoise);
                                            SetLabelValue(FtotalFPN_caption, _ftotalFpn);
                                        }));

                    fanalyze = 0;
                }


                for (row = 0; row < FrameHeight; row++)
                {
                    for (col = 0; col < FrameWidth; col++)
                    {
                        _imageFArray[frameno, row, col] = _itempArray[row, col];
                    }
                }

                if (analysisBoxVal)
                {
                    EXEC(new Action(delegate
                                        {
                                            analysis_label.Content = "N-Frames";
                                            nframelabel.Content = "N Frame";
                                        }));
                    if (frameno == numberOfFrames - 1)
                    {
                        frameno = 0;
                        fanalyze = 1;
                    }
                    else
                    {
                        frameno++;
                    }
                }
                else
                {
                    EXEC(new Action(delegate
                                        {
                                            analysis_label.Content = "2-Frames";
                                            nframelabel.Content = "2 Frame";
                                        }));
                    if (frameno == 2)
                    {
                        frameno = 0;
                        fanalyze = 2;
                    }
                    else
                    {
                        frameno++;
                    }
                }

                if (videoSaveBoxVal)
                {
                    streamname = String.Format("C:\\tmp\\{0}{1}.bmp", Videoname.Text, streamno.ToString());
                    SaveStream2X(streamname);
                    streamno++;
                }
                else
                {
                    streamno = 0;
                }

                /*EXEC(new Action(delegate
                {
                    TimeSpan tz = DateTime.Now - da;
                    Memo1.AppendText(tz.Seconds.ToString() + "." + tz.Milliseconds.ToString("000") + " seconds to analyze\n");
                    Memo1.ScrollToEnd();
                }));

                da = DateTime.Now;*/

                var pixels = new byte[FrameWidth*FrameHeight*3*4];
                for (row = 0; row < FrameHeight*2; row++)
                {
                    for (col = 0; col < FrameWidth*2; col++)
                    {
                        pixels[3*(row*FrameWidth*2 + col)] = _imageData[row, col].R;
                        pixels[3*(row*FrameWidth*2 + col) + 1] = _imageData[row, col].G;
                        pixels[3*(row*FrameWidth*2 + col) + 2] = _imageData[row, col].B;
                    }
                }

                /*TimeSpan ts = DateTime.Now - da;*/

                EXEC(new Action(delegate
                                    {
                                        BitmapSource bms = BitmapSource.Create(FrameWidth*2, FrameHeight*2, 96, 96,
                                                                               PixelFormats.Rgb24,
                                                                               BitmapPalettes.Halftone256, pixels,
                                                                               FrameWidth*2*3);
                                        image1.Source = bms;
                                        /*Memo1.AppendText(ts.Seconds.ToString() + "." + ts.Milliseconds.ToString("000") + " seconds to render\n");
                                        Memo1.ScrollToEnd();*/
                                    }));
            } while (_videoActive);
        }

        /// <summary>
        /// Load defect data from file
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void LoadDefects(object sender, RoutedEventArgs e)
        {
            int i;
            string[] lines;
            OpenFileDialog ofd;
            DefectCheckBox.IsChecked = true;
            ofd = new OpenFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            if ((bool) ofd.ShowDialog())
            {
                lines = File.ReadAllLines(ofd.FileName);
                for (i = 0; i < 30000; i++)
                {
                    if (i < lines.Length && lines[i].Contains(' '))
                    {
                        _defectArrayX[i] = byte.Parse(lines[i].Split(' ')[0]);
                        _defectArrayY[i] = byte.Parse(lines[i].Split(' ')[0]);
                    }
                }
                _useDefectData = true;
            }
        }

        /// <summary>
        /// Save test data as a text file
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SaveTestClick(object sender, RoutedEventArgs e)
        {
            int row, col, cnt = 0;
            var output = new List<string>();
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            if ((bool) sfd.ShowDialog())
            {
                for (row = 0; row < FrameHeight; row++)
                {
                    for (col = 0; col < FrameWidth; col++)
                    {
                        cnt += _itempArray[row, col];
                    }
                    output.Add(String.Format("{0}", cnt/FrameWidth));
                }
                File.WriteAllLines(sfd.FileName, output);
            }
        }

        /// <summary>
        /// Save frame distribution data
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrameDistribution(object sender, RoutedEventArgs e)
        {
            int row, col, c;
            var distTable = new int[1024];
            var output = new List<string>();
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            for (row = 0; row < FrameHeight; row++)
            {
                for (col = 0; col < FrameWidth; col++)
                {
                    distTable[_itempArray[row, col]]++;
                }
            }
            if ((bool) sfd.ShowDialog())
            {
                for (c = 0; c < 1024; c++)
                {
                    output.Add(String.Format("{0}", distTable[c]));
                }
                File.WriteAllLines(sfd.FileName, output);
                Memo1.AppendText("Distribution has been written\n");
                Memo1.ScrollToEnd();
            }
        }

        /// <summary>
        /// Save defect data as a file
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SaveDefects1Click(object sender, RoutedEventArgs e)
        {
            int row, col, dlevel, cnt;
            double avrg;
            var output = new List<string>();
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            if ((bool) sfd.ShowDialog())
            {
                cnt = 0;
                avrg = 0;
                dlevel = int.Parse(defect_min.Text);
                for (col = 3; col < FrameWidth - 1; col++)
                {
                    for (row = 3; row < FrameHeight - 1; row++)
                    {
                        if (Math.Abs(_itempArray[row, col] - avrg) > dlevel)
                        {
                            output.Add(String.Format("{0} {1}", col, row));
                            cnt++;
                        }
                    }
                }
                Memo1.AppendText(String.Format("{0} defects written", cnt));
                Memo1.ScrollToEnd();
                File.WriteAllLines(sfd.FileName, output);
            }
        }

        /// <summary>
        /// Save a bitmap of the contents of the canvas
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SaveBMP2Xcorr1Click(object sender, RoutedEventArgs e)
        {
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Bitmap | *.bmp", DefaultExt = "bmp"};
            if ((bool) sfd.ShowDialog())
            {
                byte[] bmPx2DataM = (from byte b in _bmPx2Data select b).ToArray();
                BitmapSource bms = BitmapSource.Create(FrameWidth*2, FrameHeight*2, 96, 96, PixelFormats.Gray8,
                                                       BitmapPalettes.Gray256, bmPx2DataM, FrameWidth*2);
                var be = new BmpBitmapEncoder();
                be.Frames.Add(BitmapFrame.Create(bms));
                var fs = new FileStream(sfd.FileName, FileMode.Create);
                be.Save(fs);
                fs.Close();
            }
        }

        /// <summary>
        /// Save row distribution data
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void RowDistributionsClick(object sender, RoutedEventArgs e)
        {
            int row, col, c;
            var distTableR = new int[FrameHeight,1024];
            for (row = 0; row < FrameHeight; row++)
            {
                for (col = 0; col < FrameWidth; col++)
                {
                    distTableR[row, _itempArray[row, col]]++;
                }
            }

            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            if ((bool) sfd.ShowDialog() == false)
                return;

            string output = "S ";
            for (row = 0; row < FrameHeight; row++)
                output += String.Format(" {0}", _adcSData[row]);
            output += " \n";
            for (c = 0; c < 1024; c++)
            {
                output += String.Format("{0} ", c);
                for (row = 0; row < FrameHeight; row++)
                    output += String.Format(" {0}", distTableR[row, c]);
                output += " \n";
            }
            File.WriteAllText(sfd.FileName, output);
            Memo1.AppendText("Distribution has been written\n");
            Memo1.ScrollToEnd();
        }

        /// <summary>
        /// Called to run SSLAR tests (12 frames).
        /// Does NOT run as an async process (yet) - this means the form WILL freeze during runtime.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void RunAllClick(object sender, RoutedEventArgs e)
        {
            if (!_portOpen) return;
            const string bmpNom = "nom_image";
            const string bmpSslar = "sslar_image";
            const string framefileNom = "nom_frame";
            const string framefileSslar = "sslar_frame";
            const string rowdistNom = "nRowDistr";
            const string rowdistSslar = "sRowDistr";


            FTDI.FT_STATUS portStatus;
            int readCount,
                ftBufCount,
                row,
                col,
                cc,
                i,
                j,
                cf,
                temprow,
                tempcol;

            int oscUpdownVal = 0;
            bool allNomVal = false;
            bool defectCheckBoxVal = false;
            bool amapEnVal = false;
            bool vflipVal = false;
            bool hflipVal = false;
            bool sslarWriteVal = false;
            double stepVal = 0;
            double thresholdVal = 0;
            int mseThreshVal = 0;
            EXEC(new Action(delegate
                                {
                                    oscUpdownVal = osc_updown.SelectedIndex;
                                    allNomVal = (bool) all_nom.IsChecked;
                                    defectCheckBoxVal = (bool) DefectCheckBox.IsChecked;
                                    amapEnVal = (bool) Amap_en.IsChecked;
                                    vflipVal = (bool) Vflip.IsChecked;
                                    hflipVal = (bool) Hflip.IsChecked;
                                    sslarWriteVal = (bool) sslar_write.IsChecked;
                                    stepVal = _stepSpinner.Value;
                                    thresholdVal = _thresholdSpinner.Value;
                                    _xstr = int.Parse(xbas.Text);
                                    _ystr = int.Parse(ybas.Text);
                                    _dx = int.Parse(deltax.Text);
                                    _dy = int.Parse(deltay.Text);
                                    mseThreshVal = int.Parse(mse_thresh.Text);
                                }));

            uint readResult;
            FTDI.FT_STATUS ftIOStatus;
            byte[] dataArray;
            byte c, fr;
            double it;

            double[] sit = new double[12];
            double[] sfps = new double[12];
            double sFavrg, sFavrgNom, sFavrgSslar, smse, smae, sm;
            double spspnr, cCorr, cCorrZ, cc0, cc1, cc2, cc0Z, cc1Z, cc2Z;
            string typ1;

            readCount = 150*201*2 + 3;
            readResult = 0;
            for (fr = 0; fr < 12; fr++)
            {
                if (allNomVal && (fr == 0 || fr == 6))
                {
                    Memo1.AppendText("NOM DACs\n");
                    Memo1.ScrollToEnd();
                    FtWriteControlByte(0xFF);
                    dataArray = LoadDACArray();
                    dataArray[23] |= 0x02;
                    FtWriteDacData(dataArray);
                }
                else
                {
                    if (fr == 6)
                    {
                        Memo1.AppendText("SSLAR DACs\n");
                        Memo1.ScrollToEnd();
                        FtWriteControlByte(0xFF);
                        dataArray = LoadDACArray();
                        dataArray[23] &= 0xFD;
                        FtWriteDacData(dataArray);
                    }
                    if (fr == 0)
                    {
                        Memo1.AppendText("NOM DACs");
                        Memo1.ScrollToEnd();
                        FtWriteControlByte(0xFF);
                        dataArray = LoadDACArray();
                        dataArray[23] |= 0x02;
                        FtWriteDacData(dataArray);
                    }
                }

                Memo1.AppendText(String.Format("{0}\n", fr));
                Memo1.ScrollToEnd();
                FtWriteControlByte(0x0F);
                do
                {
                    portStatus = _ftHandle.GetRxBytesAvailable(ref _ftQBytes);
                    if (portStatus != FTDI.FT_STATUS.FT_OK)
                        FtErrorReport("FT_GetQueueStatus", portStatus);
                } while (_ftQBytes > readCount);
                ftIOStatus = _ftHandle.Read(_ftInBuffer, (uint) readCount, ref readResult);
                if (ftIOStatus != FTDI.FT_STATUS.FT_OK)
                    FtErrorReport("FT_Read", ftIOStatus);

                it = _ftInBuffer[60300] + 256*_ftInBuffer[60301] + 65536*_ftInBuffer[60302];
                if (oscUpdownVal == 1) sit[fr] = it/4000;
                if (oscUpdownVal == 2) sit[fr] = it/10000;
                if (oscUpdownVal == 3) sit[fr] = it/12000;
                if (oscUpdownVal == 4) sit[fr] = it/16000;
                if (oscUpdownVal == 5) sit[fr] = it/20000;
                else sit[fr] = it/10000;

                ftBufCount = 0;
                for (row = 0; row < FrameHeight; row++)
                {
                    c = _ftInBuffer[ftBufCount];
                    ftBufCount++;
                    cc = c + 256*_ftInBuffer[ftBufCount];
                    ftBufCount++;
                    _sadcSData[fr, row] = (int) Math.Round(cc/32.0);
                    for (col = 0; col < FrameWidth; col++)
                    {
                        c = _ftInBuffer[ftBufCount];
                        ftBufCount++;
                        cc = c + 256*(_ftInBuffer[ftBufCount]);
                        _sitempArray[fr, row, col] = cc;
                        ftBufCount++;
                    }
                }
            }

            for (fr = 0; fr < 12; fr++)
            {
                if (_useDefectData && defectCheckBoxVal)
                {
                    for (cf = 0; cf < 30000; cf++)
                    {
                        i = _defectArrayY[cf];
                        j = _defectArrayX[cf];
                        if (i > 0 && j > 0 && j < FrameWidth && i < FrameHeight)
                        {
                            _sitempArray[fr, i, j] = (int) Math.Round((_itempArray[i - 1, j - 1] +
                                                                      _itempArray[i - 1, j] + _itempArray[i - 1, j + 1] +
                                                                      _itempArray[i, j - 1] + _itempArray[i, j + 1] +
                                                                      _itempArray[i + 1, j - 1] + _itempArray[i + 1, j] +
                                                                      _itempArray[i + 1, j + 1])/8.0);
                            _stempArray[fr, i, j] = (byte) Math.Round((_tempArray[i - 1, j - 1] +
                                                                      _tempArray[i - 1, j] + _tempArray[i - 1, j + 1] +
                                                                      _tempArray[i, j - 1] + _tempArray[i, j + 1] +
                                                                      _tempArray[i + 1, j - 1] + _tempArray[i + 1, j] +
                                                                      _tempArray[i + 1, j + 1])/8.0);
                        }
                    }
                }
            }

            for (fr = 0; fr < 11; fr++)
            {
                for (row = 0; row < FrameHeight; row++)
                    for (col = 0; col < FrameWidth; col++)
                    {
                        cc = _sitempArray[fr, row, col];
                        if (amapEnVal)
                            _stempArray[fr, row, col] = _aGammaTable[cc];
                    }
            }

            for (fr = 0; fr < 12; fr++)
            {
                for (row = 0; row < FrameHeight; row++)
                    for (col = 0; col < FrameWidth; col++)
                    {
                        if (vflipVal && hflipVal)
                        {
                            _sImageArray[fr, row, col] = _stempArray[fr, FrameHeight - 1 - row, FrameWidth - 1 - col];
                            _siImageArray[fr, row, col] = _sitempArray[fr, FrameHeight - 1 - row, FrameWidth - 1 - -col];
                        }
                        if (vflipVal && !hflipVal)
                        {
                            _sImageArray[fr, row, col] = _stempArray[fr, FrameHeight - 1 - row, col];
                            _siImageArray[fr, row, col] = _sitempArray[fr, FrameHeight - 1 - row, col];
                        }
                        if (!vflipVal && hflipVal)
                        {
                            _sImageArray[fr, row, col] = _stempArray[fr, row, FrameWidth - 1 - col];
                            _siImageArray[fr, row, col] = _sitempArray[fr, row, FrameWidth - 1 - col];
                        }
                        if (!vflipVal && !hflipVal)
                        {
                            _sImageArray[fr, row, col] = _stempArray[fr, row, col];
                            _siImageArray[fr, row, col] = _sitempArray[fr, row, col];
                        }
                    }
            }
            
            for (fr = 0; fr < 12; fr++)
            {
                for (row = 0; row < FrameHeight; row++)
                    for (col = 0; col < FrameWidth; col++)
                    {
                        _stempArray[fr, row, col] = _sImageArray[fr, row, col];
                        _sitempArray[fr, row, col] = _siImageArray[fr, row, col];
                        c = _sImageArray[fr, row, col];
                        for (temprow = 0; temprow < 2; temprow++)
                            for (tempcol = 0; tempcol < 2; tempcol++)
                            {
                                _sbmpData[fr, row*2 + temprow, col*2 + tempcol] = _gammaTable[c];
                            }

                        if (sslarWriteVal)
                        {
                            string filename;
                            if (fr < 6)
                                filename = String.Format("{0}_{1}{2}{3}.txt", stepVal, thresholdVal, framefileNom, fr);
                            else
                                filename = String.Format("{0}_{1}{2}{3}.txt", stepVal, thresholdVal, framefileSslar,
                                                         fr);
                            string output = "";
                            for (row = 0; row < FrameHeight; row++)
                            {
                                output += String.Format("{0} {1} ", row, _sadcSData[fr, row]);
                                for (col = 0; col < FrameWidth; col++)
                                    output += String.Format("{0} ", _sitempArray[fr, row, col]);
                                output += " \n";
                            }
                            Memo1.AppendText(String.Format("Frame{0}", fr));
                            Memo1.ScrollToEnd();
                            File.WriteAllText(filename, output);
                        }
                    }
            }

            for (fr = 0; fr < 11; fr++)
            {
                for (row = 0; row < FrameHeight; row++)
                {
                    for (i = 0; i < 1024; i++)
                    {
                        for (col = 0; col < FrameWidth; col++)
                        {
                            cc = _sitempArray[fr, row, col];
                            _sDistTableR[fr, row, cc]++;
                        }
                    }
                }
                if (sslarWriteVal)
                {
                    string filename;
                    if (fr < 6)
                        filename = String.Format("{0}_{1}{2}{3}.txt", stepVal, thresholdVal, rowdistNom, fr);
                    else
                        filename = String.Format("{0}_{1}{2}{3}.txt", stepVal, thresholdVal, rowdistSslar, fr);
                    string output = "";
                    output += "S ";
                    for (row = 0; row < FrameHeight; row++)
                    {
                        output += String.Format(" {0}", _sadcSData[fr, row]);
                    }
                    output += " \n";
                    for (i = 0; i < 1023; i++)
                    {
                        output += String.Format("{0} ", i);
                        for (row = 0; row < FrameHeight; row++)
                        {
                            output += String.Format(" {0}", _sDistTableR[fr, row, i]);
                        }
                        output += " \n";
                    }
                    File.WriteAllText(filename, output);
                }
                Memo1.AppendText(String.Format("Distribution {0}", fr));
                Memo1.ScrollToEnd();
            }

            for (fr = 0; fr < 12; fr++)
            {
                if (sslarWriteVal)
                {
                    string filename;
                    if (fr < 6)
                        filename = String.Format("{0}_{1}{2}{3}.bmp", stepVal, thresholdVal, bmpNom, fr);
                    else
                        filename = String.Format("{0}_{1}{2}{3}.bmp", stepVal, thresholdVal, bmpSslar, fr);
                    var px = new byte[FrameWidth*FrameHeight*4];
                    for (row = 0; row < FrameHeight*2; row++)
                    {
                        for (col = 0; col < FrameWidth*2; col++)
                        {
                            px[row*FrameWidth*2 + col] = _sbmpData[fr, row, col];
                        }
                    }
                    BitmapSource bms = BitmapSource.Create(FrameWidth*2, FrameHeight*2, 96, 96, PixelFormats.Gray8,
                                                           BitmapPalettes.Gray256, px, FrameWidth*2);
                    var be = new BmpBitmapEncoder();
                    be.Frames.Add(BitmapFrame.Create(bms));
                    var fs = new FileStream(filename, FileMode.Create);
                    be.Save(fs);
                    fs.Close();
                }
            }

            for (row = _ystr; row < _ystr + _dy; row++)
            {
                for (col = _xstr; col < _xstr + _dx; col++)
                {
                    _sitempArray[0, row, col] = (int) Math.Round((_sitempArray[1, row, col] + _sitempArray[2, row, col] +
                                                                 _sitempArray[3, row, col] + _sitempArray[4, row, col])/
                                                                4.0);
                    _sitempArray[6, row, col] = (int) Math.Round((_sitempArray[7, row, col] + _sitempArray[8, row, col] +
                                                                 _sitempArray[9, row, col] + _sitempArray[10, row, col])/
                                                                4.0);
                }
            }

            sFavrgNom = 0.0;
            sFavrgSslar = 0.0;
            cc = _dx*_dy;
            for (row = _ystr; row < _ystr + _dy; row++)
                for (col = _xstr; col < _xstr + _dx; col++)
                {
                    sFavrgNom += _sitempArray[0, row, col]/(double) cc;
                    sFavrgSslar += _sitempArray[6, row, col]/(double) cc;
                }
            sFavrg = (sFavrgNom + sFavrgSslar)/2.0;

            smse = 0.0;
            smae = 0.0;
            for (row = _ystr; row < _ystr + _dy; row++)
                for (col = _xstr; col < _xstr + _dx; col++)
                {
                    sm =
                        Math.Abs(((_sitempArray[0, row, col]/sFavrgNom) - (_sitempArray[6, row, col]/sFavrgSslar))*
                                 sFavrg);
                    if ((int) Math.Round(sm) < mseThreshVal)
                    {
                        smse +=
                            Math.Pow(
                                (((_sitempArray[0, row, col]/sFavrgNom) - (_sitempArray[6, row, col]/sFavrgSslar))*
                                 sFavrg)/cc, 2);
                        smae += sm/cc;
                    }
                }

            spspnr = 10*Math.Log10(1046529/smse);
            cc0 = 0.0;
            cc1 = 0.0;
            cc2 = 0.0;
            cc0Z = 0.0;
            cc1Z = 0.0;
            cc2Z = 0.0;
            for (row = _ystr; row < _ystr + _dy; row++)
                for (col = _xstr; col < _xstr + _dx; col++)
                {
                    sm =
                        Math.Abs(((_sitempArray[0, row, col]/sFavrgNom) - (_sitempArray[6, row, col]/sFavrgSslar))*
                                 sFavrg);
                    if ((int) Math.Round(sm) < mseThreshVal)
                    {
                        cc0 += _sitempArray[0, row, col]*_sitempArray[6, row, col];
                        cc1 += _sitempArray[0, row, col]*_sitempArray[0, row, col];
                        cc2 += _sitempArray[6, row, col]*_sitempArray[6, row, col];

                        cc0Z += (_sitempArray[0, row, col] - sFavrgNom)*(_sitempArray[6, row, col] - sFavrgSslar);
                        cc1Z += (_sitempArray[0, row, col] - sFavrgNom)*(_sitempArray[0, row, col] - sFavrgNom);
                        cc2Z += (_sitempArray[6, row, col] - sFavrgSslar)*(_sitempArray[6, row, col] - sFavrgSslar);
                    }
                }
            cCorr = cc0/Math.Sqrt(cc1*cc2);
            cCorrZ = cc0Z/Math.Sqrt(cc1Z*cc2Z);

            EXEC(new Action(delegate
                                {
                                    SetLabelValue(sslar_avrg, sFavrg);
                                    SetLabelValue(pspnr_level, spspnr);
                                    SetLabelValue(MSE_level, smse);
                                    SetLabelValue(MAE_level, smae);
                                    SetLabelValue(CCorr_level, cCorr);
                                    SetLabelValue(CCorrZ_level, cCorrZ);
                                }));

            for (row = 0; row < FrameHeight; row++)
                for (col = 0; col < FrameWidth; col++)
                {
                    for (temprow = 0; temprow < 2; temprow++)
                        for (tempcol = 0; tempcol < 2; tempcol++)
                        {
                            _sbmpData[0, row*2 + temprow, col*2 + tempcol] =
                                (byte) Math.Round((_sbmpData[1, row*2 + tempcol, col*2 + tempcol] +
                                                   _sbmpData[2, row*2 + temprow, col*2 + tempcol] +
                                                   _sbmpData[3, row*2 + tempcol, col*2 + tempcol] +
                                                   _sbmpData[4, row*2 + tempcol, col*2 + tempcol])/4.0);
                            _sbmpData[1, row*2 + temprow, col*2 + tempcol] =
                                (byte) Math.Round((_sbmpData[7, row*2 + tempcol, col*2 + tempcol] +
                                                   _sbmpData[8, row*2 + temprow, col*2 + tempcol] +
                                                   _sbmpData[9, row*2 + tempcol, col*2 + tempcol] +
                                                   _sbmpData[10, row*2 + tempcol, col*2 + tempcol])/4.0);
                        }
                }

            if (allNomVal)
                typ1 = "NOM";
            else
                typ1 = "SSLAR";

            for (fr = 0; fr < 2; fr++)
            {
                string filename;
                if (fr == 0)
                    filename = String.Format("{0}_{1}{2}{3}AVRG.bmp", stepVal, thresholdVal, bmpNom, fr);
                else
                    filename = String.Format("{0}_{1}{2}{3}AVRG.bmp", stepVal, thresholdVal, bmpSslar, fr);
                var px = new byte[FrameWidth*FrameHeight*4];
                for (row = 0; row < FrameHeight*2; row++)
                    for (col = 0; col < FrameWidth*2; col++)
                        px[row*FrameWidth*2 + col] = _sbmpData[fr, row, col];
                BitmapSource bms = BitmapSource.Create(FrameWidth*2, FrameHeight*2, 96, 96, PixelFormats.Gray8,
                                                       BitmapPalettes.Gray256, px, FrameWidth*2);
                var be = new BmpBitmapEncoder();
                be.Frames.Add(BitmapFrame.Create(bms));
                var fs = new FileStream(filename, FileMode.Create);
                be.Save(fs);
                fs.Close();
                Memo1.AppendText(String.Format("BMP File {0}\n", fr));
                Memo1.ScrollToEnd();

                string output = String.Format("{0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {10} {11} {12} {13} {14}\n", typ1,
                                              ((sfps[1] + sfps[2] + sfps[3] + sfps[4])/4).ToString("00.000"),
                                              ((sit[1] + sit[2] + sit[3] + sit[4])/4).ToString("00.000"),
                                              ((sfps[7] + sfps[8] + sfps[9] + sfps[10])/4).ToString("00.000"),
                                              ((sit[7] + sit[8] + sit[9] + sit[10])/4).ToString("00.000"),
                                              stepVal, thresholdVal, sFavrgNom.ToString("00.000"),
                                              sFavrgSslar.ToString("00.000"), sFavrg.ToString("00.000"),
                                              smse.ToString("00.000"), smae.ToString("00.000"),
                                              cCorr.ToString("00.000"), cCorrZ.ToString("00.000"),
                                              spspnr.ToString("00.000"));

                File.AppendAllText(_sslardatafilename, output);
            }
        }

        /// <summary>
        /// Construct the SSLAR Analysis File header
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void SslarAnalysisFileBuildClick(object sender, RoutedEventArgs e)
        {
            _sslardatafilename = SSLAR_Analysis_file.Text;
            File.WriteAllText(_sslardatafilename,
                              "TYPE FPSn ITn FPSs ITs STEP THRES AVRG(nom) AVRG(sslar) AVRG(both) MSE MAE CCorr CCorrZ PSPNR\n");
        }

        /// <summary>
        /// Saves image data to a filename - to be used while streaming
        /// </summary>
        /// <param name="filename"></param>
        private void SaveStream2X(string filename)
        {
            int row, col;
            var fs = new FileStream(filename, FileMode.Create);
            var px = new byte[FrameWidth*FrameHeight*4];
            for (row = 0; row < FrameHeight; row++)
                for (col = 0; col < FrameWidth; col++)
                    px[row*FrameWidth*2 + col] = _bmPx2Data[row, col];
            BitmapSource bms = BitmapSource.Create(FrameWidth*2, FrameHeight*2, 96, 96, PixelFormats.Gray8,
                                                   BitmapPalettes.Gray256, px, FrameWidth*2);
            var be = new BmpBitmapEncoder();
            be.Frames.Add(BitmapFrame.Create(bms));
            be.Save(fs);
            fs.Close();
            Memo1.AppendText("BMP File was written");
            Memo1.ScrollToEnd();
        }

        /// <summary>
        /// Write analysis data
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void WriteAnalysisDatatoFileClick(object sender, RoutedEventArgs e)
        {
            int dx, dy;
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            string output = "";
            if ((bool) sfd.ShowDialog())
            {
                dx = int.Parse(deltax.Text);
                dy = int.Parse(deltay.Text);
                output += String.Format("File name: {0}\n", sfd.FileName);
                output += "Analysis Results :\n";
                if ((bool) input_refered.IsChecked)
                    output += "      - Input referred noise\n";
                else
                    output += "      - Output referred noise\n";
                if ((bool) Nconvert.IsChecked)
                    output += "      - Normal noise voltage\n";
                else
                    output += "      - Squared noise voltage\n";
                if ((bool) Nperconvert.IsChecked)
                    output += "      - Noise in %LSB of average signal\n";
                else
                    output += "      - Noise in LSB\n";
                output += String.Format("Signal Chain Gain :{0}\n", _gainsett.ToString("0.0000"));
                output += String.Format("VLN Bias Setting :{0}\n", _vlnSpinner.Value.ToString());
                output += String.Format("AMP Bias Setting :{0}\n", _ampbiasSpinner.Value.ToString());
                output +=
                    "Light FPS IT P FPNn FPNv FPNh FPNp NTEMPn NTEMPv NTEMPh NTEMPp NTOTn NTOTv NTOTh NTOTp NFlick NFrame NumSamples dx dy xstart ystart\n";
                output +=
                    String.Format(
                        "{0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {10} {11} {12} {13} {14} {15} {16} {17} {18} {19} {20} {21} {22}\n",
                        light_level.Text, fps_caption.Content, it_caption.Content, _fullNframeAvrg.ToString("0.0000"),
                        _ftotalFpn.ToString("0.0000"), _ctotalFpn.ToString("0.0000"), _rtotalFpn.ToString("0.0000"),
                        _ptotalFpn.ToString("0.0000"), _ftempNoise.ToString("0.0000"), _ctempNoise.ToString("0.0000"),
                        _rtempNoise.ToString("0.0000"), _ptempNoise.ToString("0.0000"), _ftotalNoise.ToString("0.0000"),
                        _ctotalNoise.ToString("0.0000"), _rtotalNoise.ToString("0.0000"), _ptotalNoise.ToString("0.0000"),
                        _flickerNoise.ToString("0.0000"),
                        num_frames.Text, (dx*dy).ToString(), deltax.Text, deltay.Text, xbas.Text, ybas.Text);
                File.WriteAllText(sfd.FileName, output);
                Memo1.AppendText("Analysis file ready to be append...\n");
                Memo1.ScrollToEnd();
            }
        }

        /// <summary>
        /// Append analysis data to file
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void AppendButtonClick(object sender, RoutedEventArgs e)
        {
            int dx, dy;
            dx = int.Parse(deltax.Text);
            dy = int.Parse(deltay.Text);
            var sfd = new SaveFileDialog {AddExtension = true, Filter = "Text Files | *.txt", DefaultExt = "txt"};
            if ((bool) sfd.ShowDialog())
            {
                string output =
                    String.Format(
                        "{0} {1} {2} {3} {4} {5} {6} {7} {8} {9} {10} {11} {12} {13} {14} {15} {16} {17} {18} {19} {20} {21} {22}\n",
                        light_level.Text, fps_caption.Content, it_caption.Content, _fullNframeAvrg.ToString("0.0000"),
                        _ftotalFpn.ToString("0.0000"), _ctotalFpn.ToString("0.0000"), _rtotalFpn.ToString("0.0000"),
                        _ptotalFpn.ToString("0.0000"), _ftempNoise.ToString("0.0000"), _ctempNoise.ToString("0.0000"),
                        _rtempNoise.ToString("0.0000"), _ptempNoise.ToString("0.0000"), _ftotalNoise.ToString("0.0000"),
                        _ctotalNoise.ToString("0.0000"), _rtotalNoise.ToString("0.0000"), _ptotalNoise.ToString("0.0000"),
                        _flickerNoise.ToString("0.0000"),
                        num_frames.Text, (dx*dy).ToString(), deltax.Text, deltay.Text, xbas.Text, ybas.Text);
                File.AppendAllText(sfd.FileName, output);
                Memo1.AppendText("Analysis data added...\n");
                Memo1.ScrollToEnd();
            }
        }

        /// <summary>
        /// Called by updown buttons to adjust their internal data and update textbox text
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void UpdownMenusS(object sender, Microsoft.Windows.Controls.SpinEventArgs e)
        {
            _spinnerController.SpinnerPressed(sender, e);
            UpdownMenus();
        }
    }
}

