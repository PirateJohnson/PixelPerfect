using Microsoft.Windows.Controls;

namespace SSLAR2_Viewer
{
    class SpinnerData
    {
        /// <summary>
        /// The minimum value for this spinner
        /// </summary>
        public int Minimum;

        /// <summary>
        /// The maximum value for this spinner
        /// </summary>
        public int Maximum;

        /// <summary>
        /// The current value of this spinner
        /// </summary>
        public int Value
        {
            get { return _val; }
            set 
            {
                _val = value;
                if (_val == Minimum)
                    Spinner.ValidSpinDirection = ValidSpinDirections.Increase;
                if (_val == Maximum)
                    Spinner.ValidSpinDirection = ValidSpinDirections.Decrease;
                if (Minimum == Maximum)
                    Spinner.ValidSpinDirection = ValidSpinDirections.None;
            }
        }
        private int _val;

        /// <summary>
        /// The spinner object tied to the values
        /// </summary>
        public ButtonSpinner Spinner;

        /// <summary>
        /// Cteate a spinner shell with a minimum, maximum, and initial value
        /// </summary>
        /// <param name="spinner">ButtonSpinner form element</param>
        /// <param name="minimum">Minimum value</param>
        /// <param name="maximum">Maximum value</param>
        /// <param name="initial">Initial value</param>
        public SpinnerData(ButtonSpinner spinner, int minimum, int maximum, int initial)
        {
            Spinner = spinner;
            Minimum = minimum;
            Maximum = maximum;
            Value = initial;
            if (initial == minimum)
                spinner.ValidSpinDirection = ValidSpinDirections.Increase;
            if (initial == maximum)
                spinner.ValidSpinDirection = ValidSpinDirections.Decrease;
            if (minimum == maximum)
                spinner.ValidSpinDirection = ValidSpinDirections.None;
        }

        /// <summary>
        /// Create a spinner shell with a minimum of 0, maximum of 63, and initial vlaue of 0.
        /// </summary>
        /// <param name="spinner">ButtonSpinner form element</param>
        public SpinnerData(ButtonSpinner spinner)
        {
            Spinner = spinner;
            Minimum = 0;
            Maximum = 63;
            Value = 0;
            spinner.ValidSpinDirection = ValidSpinDirections.Increase;
        }

        /// <summary>
        /// Creates an empty object that can be changed later
        /// </summary>
        public SpinnerData() { }
    }
}
