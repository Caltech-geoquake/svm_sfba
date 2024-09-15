#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb  2 19:01:47 2021

@author: glavrent
"""
#load variables
import pathlib
import numpy as np
import rasterio


class Willis15Vs30CA:
    
    def __init__(self, fname_vs30map_med=None, fname_vs30map_sig=None):
        #file path
        root = pathlib.Path(__file__).parent
        #vs30 data filenames
        fname_vs30map_med = '../../Raw_files/vel_model/California_map_Vs30/California_vs30_Wills15_hybrid.tif'    if fname_vs30map_med is None else fname_vs30map_med
        fname_vs30map_sig = '../../Raw_files/vel_model/California_map_Vs30/California_vs30_Wills15_hybrid_sd.tif' if fname_vs30map_sig is None else fname_vs30map_sig
        #load vs30 data
        self.vs30map_med = rasterio.open( fname_vs30map_med )
        self.vs30map_sig = rasterio.open( fname_vs30map_sig )

    def lookup(self, lonlats):
        return (
            np.fromiter(self.vs30map_med.sample(lonlats, 1), np.double),
            np.fromiter(self.vs30map_sig.sample(lonlats, 1), np.double)
        )

    def test_lookup(self):
        medians, stds = list(self.lookup([(-122.258, 37.875), (-122.295, 37.895)]))
    
        np.testing.assert_allclose(medians, [733.4, 351.9], rtol=0.01)
        np.testing.assert_allclose(stds, [0.432, 0.219],    rtol=0.01)


