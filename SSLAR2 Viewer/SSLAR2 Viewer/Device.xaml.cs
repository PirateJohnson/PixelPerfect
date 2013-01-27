using System;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;
using FTD2XX_NET;

namespace SSLAR2_Viewer
{
    /// <summary>
    /// Interaction logic for Window1.xaml
    /// </summary>
    public partial class FrmDevice
    {
        public const int DEVICE_FAIL = 0;
        public const int DEVICE_OPEN = 1;

        public bool FtEnableErrorReport = true;
        public char[] FtUsbDeviceBuffer = new char[50];
        public string SelectedDeviceSerialNumber;
        public string SelectedDeviceDescription;
        public uint SelectedDeviceIndex;
        public int SelectedDeviceResult = DEVICE_FAIL;


        public FrmDevice()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Show error report
        /// </summary>
        /// <param name="errStr">Error description</param>
        /// <param name="portStatus">Error code</param>
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
        /// Called when the window is loaded
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void WindowLoaded(object sender, RoutedEventArgs e)
        {
            int i;
            
            // Configure datagrid
            dataGrid1.Items.Clear();
            dataGrid1.Columns.Clear();
            dataGrid1.Columns.Add(new DataGridTextColumn { Header = "Device Number", Binding = new Binding("Dn") });
            dataGrid1.Columns.Add(new DataGridTextColumn { Header = "Serial Number", Binding = new Binding("Sn") });
            dataGrid1.Columns.Add(new DataGridTextColumn { Header = "Device Description", Binding = new Binding("Dd") });

            // Get FTDI basic data
            FTDI f = new FTDI();
            uint devicecount = 0;
            f.GetNumberOfDevices(ref devicecount);

            // Fill datagrid with device data
            string dd, sn, dn;
            if (devicecount == 0)
            {
                FtErrorReport("GetFTDeviceCount", FTDI.FT_STATUS.FT_DEVICE_NOT_FOUND);
            }
            for (i = 0; i < devicecount; i++)
            {
                f.OpenByIndex((uint)i);
                dn = String.Format("Device {0}", i);
                f.GetSerialNumber(out sn);
                f.GetDescription(out dd);
                f.Close();
                dataGrid1.Items.Add( new SDevice{ Dd = dd, Dn = dn, Sn = sn } );
            }
        }

        /// <summary>
        /// Called when an item is selected or deselected
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DataGrid1SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            button1.IsEnabled = (dataGrid1.SelectedIndex != -1);
        }

        /// <summary>
        /// Refresh the form and datagrid
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Button2Click(object sender, RoutedEventArgs e)
        {
            WindowLoaded(sender, e);
        }

        /// <summary>
        /// Cancel
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Button3Click(object sender, RoutedEventArgs e)
        {
            Close();
        }

        /// <summary>
        /// Select the currently selected device
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Button1Click(object sender, RoutedEventArgs e)
        {
            if (dataGrid1.SelectedIndex == -1)
                return;
            SelectedDeviceDescription = (dataGrid1.SelectedItem as SDevice).Dd;
            SelectedDeviceIndex = (uint)dataGrid1.SelectedIndex;
            SelectedDeviceSerialNumber = (dataGrid1.SelectedItem as SDevice).Sn;
            SelectedDeviceResult = DEVICE_OPEN;
            Close();
        }

        /// <summary>
        /// Select the double-clicked device
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DataGrid1MouseDoubleClick(object sender, MouseButtonEventArgs e)
        {
            if (dataGrid1.SelectedIndex == -1)
                return;
            SelectedDeviceDescription = (dataGrid1.SelectedItem as SDevice).Dd;
            SelectedDeviceIndex = (uint) dataGrid1.SelectedIndex;
            SelectedDeviceSerialNumber = (dataGrid1.SelectedItem as SDevice).Sn;
            SelectedDeviceResult = DEVICE_OPEN;
            Close();
        }


    }

    /// <summary>
    /// Used to give data to the datagrid ofd evices
    /// </summary>
    public class SDevice
    {
        public string Dn { set; get; }
        public string Sn { set; get; }
        public string Dd { set; get; }
    }
}
