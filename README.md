<img width="460" height="307" alt="Image" src="https://github.com/user-attachments/assets/3ace32eb-d17f-4460-a97f-8b2155f88ff1" />

## Overview

This project presents the MATLAB implementation for Radar Imaging, including signal modeling, direction of arrival (DoA) estimation, range estimation, and MIMO radar analysis.

## Files Included

| File Name                            | Description                                      |
|-------------------------------------|--------------------------------------------------|
| `doa_fft_single_target.m`           | DoA estimation using FFT for a single target     |
| `doa_fft_two_targets.m`             | DoA estimation with two targets + resolution     |
| `range_estimation.m`                | 2D position estimation via cross-correlation     |
| `mimo_doa_range_estimation.m`       | Joint DoA & range estimation using MIMO radar    |
| `mohammadreza_zamani_HW1_10869960.pdf` | Full technical report with explanation & results |

## Task Descriptions

### 1. System Geometry & Angular Resolution

- Constructs a ULA with optimized antenna count based on desired angular resolution (2°).
- Analyzes antenna spacing effects (`λ/2` vs `λ/4`) to avoid aliasing.

**Code:** `doa_fft_single_target.m`

### 2. DoA Estimation via FFT

- Uses spatial FFT of demodulated signals to estimate target angle.
- Resolution computed by analyzing FFT sidelobes.
- Extended to multiple targets with `findpeaks`.

### 3. 2D Position Estimation

- Models radar signal as a sinc-modulated chirp.
- Applies round-trip time delay and estimates target range using cross-correlation.

### 4. MIMO Radar

- Constructs a virtual array using 2 Tx and 29 Rx antennas (→ 58 elements).
- Estimates DoA and range simultaneously.
- FFT used for angular domain; cross-correlation for range.

## Sample Results

- **DoA Estimation** Accuracy: < 0.2° error for single/multiple targets
- **Range Estimation** Accuracy: ±0.01 m (using 1 GHz bandwidth)
- **Resolution** Achieved: Angular ≈ 2°, Range ≈ 0.15 m
