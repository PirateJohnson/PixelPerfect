using System.Collections.Generic;
using Microsoft.Windows.Controls;

namespace SSLAR2_Viewer
{
    class SpinnerController
    {
        private readonly List<SpinnerData> _spinnerList;
        
        /// <summary>
        /// Creates a new SpinnerController object
        /// </summary>
        public SpinnerController()
        {
            _spinnerList = new List<SpinnerData>();
        }

        /// <summary>
        /// Can be called by a spinner event to adjust data prior to data processing.
        /// </summary>
        /// <param name="sender">The ButtonSpinner that was pressed</param>
        /// <param name="e">The data returned by the ButtonSpinner's Spin event</param>
        public void SpinnerPressed(object sender, SpinEventArgs e)
        {
            foreach (SpinnerData d in _spinnerList)
            {
                if (d.Spinner == sender as ButtonSpinner)
                {
                    if (e.Direction == SpinDirection.Increase)
                    {
                        d.Value++;
                        if (d.Value >= d.Maximum)
                        {
                            d.Value = d.Maximum;
                            d.Spinner.ValidSpinDirection = ValidSpinDirections.Decrease;
                        }
                        else
                        {
                            d.Spinner.ValidSpinDirection = ValidSpinDirections.Increase | ValidSpinDirections.Decrease;
                        }
                    } 
                    else
                    {
                        d.Value--;
                        if (d.Value <= d.Minimum)
                        {
                            d.Value = d.Minimum;
                            d.Spinner.ValidSpinDirection = ValidSpinDirections.Increase;
                        }
                        else
                        {
                            d.Spinner.ValidSpinDirection = ValidSpinDirections.Increase | ValidSpinDirections.Decrease;
                        }
                    }
                    return;
                }
            }
        }

        /// <summary>
        /// Add a spinner to this controller's database with Min = 0, Max = 63, Default = 0
        /// </summary>
        /// <param name="spinner">The ButtonSpinner to add</param>
        /// <returns>The spinner data (from which a value can be taken)</returns>
        public SpinnerData AddSpinner(ButtonSpinner spinner)
        {
            SpinnerData d = new SpinnerData(spinner);
            _spinnerList.Add(d);
            return d;
        }

        /// <summary>
        /// Add a spinner to this controller's database
        /// </summary>
        /// <param name="spinner">The ButtonSpinner to add</param>
        /// <param name="minimum">The minimum value for the spinner</param>
        /// <param name="maximum">The maximum value for the spinner</param>
        /// <param name="initial">The initial value for the spinner</param>
        /// <returns>The spiner data (from which a value can be taken)</returns>
        public SpinnerData AddSpinner(ButtonSpinner spinner, int minimum, int maximum, int initial)
        {
            SpinnerData d = new SpinnerData(spinner, minimum, maximum, initial);
            _spinnerList.Add(d);
            return d;
        }
    }
}
