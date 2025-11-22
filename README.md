# module_13_bmi_calculator

A new Flutter project bmi_calculator.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Flutter BMI Calculator

A comprehensive BMI Calculator built with Flutter that supports multiple units (metric and imperial) and provides clear, color-coded feedback based on the result.

This project fulfills all requirements for the assignment, including multi-unit conversion, validation, and bonus UX features.
Features

# Multi-Unit Input:

Weight: Kilograms (kg) or Pounds (lb).

Height: Centimeters (cm), Meters (m), or Feet & Inches (ft/in).

Accurate Conversions: Automatically converts all inputs to metric (kg/m²) for calculation.

Instant Validation: Provides user-friendly error messages for empty, invalid (e.g., 1.2.3), or zero inputs.

Color-Coded Results: The result card and category chip change color based on the BMI category.

Smart UX: Automatically carries over inches to feet (e.g., 5 ft 15 in is treated as 6 ft 3 in).

# Core Logic

1. Unit Conversions

All inputs are converted to standard metric units before the BMI calculation:

Pounds to Kilograms:
kg = lb * 0.45359237

Centimeters to Meters:
m = cm / 100

Feet/Inches to Meters:
m = (feet * 12 + inch) * 0.0254

2. BMI Calculation

The standard metric formula is used:

BMI = weight_kg / (height_m)²

The final BMI score is displayed to one decimal place.

# 3. Category & Color Mapping
The app categorizes the result and assigns a color based on the World Health Organization (WHO) standard:
# Catagoy         BMI Range      Color
  Underweight       <18.5        Blue
  Normal         (18.5 - 24.9)   Green
  overweight     (25.0 - 29.9)   orenge
  Obese            >= 30.0       Red


APK link if available: https://drive.google.com/file/d/1CMC2CC74VzCg2cQhPdVpnMkYj5Y3ukc_/view?usp=sharing
