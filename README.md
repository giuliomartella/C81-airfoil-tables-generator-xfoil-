# C81 Airfoil Tables Generator (Xfoil)

This MATLAB code is designed to build `.c81` airfoil tables using data obtained from Xfoil.

### Instructions:
1. Install Xfoil.
2. Use `save_polars` to extract Xfoil data.
3. Define the Reynolds and Mach numbers needed for your analysis.
4. Save the `.dat` file containing the 2D coordinates of your airfoil, and link its path in `createC81` (5th row).
5. Run `createC81` to generate the `.c81` file.

**Note:** This code has been written for a specific use case and its reliability has not been fully proven. If computing more than 9 Mach numbers, update `createC81` (15th row).

Feel free to modify and improve the code according to your specific requirements.

